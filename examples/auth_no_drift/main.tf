# =============================================================================
# POC: Authentication WITHOUT Token Drift
# Module: Azure/avm-res-web-site/azurerm  version = "0.15.1"
#
# DRIFT ROOT CAUSES FIXED IN THIS FILE:
#
# [FIX 1] random_integer — uses `keepers` so it is NEVER regenerated unless
#         the region list changes intentionally. Without keepers, adding any
#         region to locals.tf destroys ALL resources.
#
# [FIX 2] Application Insights — connection_string is stored as a Key Vault
#         secret. The App Service app setting value is the STATIC KEY NAME
#         string "@Microsoft.KeyVault(SecretUri=...)" which does NOT change
#         when the instrumentation key rotates. lifecycle.ignore_changes on
#         the KV secret prevents Terraform from updating the secret value
#         and triggering a web app update on every run.
#
# [FIX 3] auth_settings_v2 / Azure AD — the client secret is referenced by
#         the SETTING NAME "AAD_CLIENT_SECRET", never inline. The actual value
#         lives in Key Vault and is fetched by Azure at runtime. Terraform
#         only manages the static string "AAD_CLIENT_SECRET", which NEVER
#         changes, so there is zero plan diff on every subsequent run.
#
# [FIX 4] login.token_store — explicitly set enabled = true and provide a
#         token_refresh_extension_hours value. If you omit these, Azure
#         may auto-populate them on first deploy, and Terraform will see
#         a null → value diff on the next plan.
# =============================================================================

# ---------------------------------------------------------------------------
# FIX 1: Stable region selection — keepers prevents regeneration
# ---------------------------------------------------------------------------
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0

  # keepers: the integer is only regenerated when this map changes.
  # As long as the region list stays the same, this value is FROZEN.
  keepers = {
    regions_fingerprint = join(",", local.azure_regions)
  }
}

# ---------------------------------------------------------------------------
# Naming module — provides CAF-compliant unique names
# ---------------------------------------------------------------------------
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# ---------------------------------------------------------------------------
# Log Analytics Workspace (dependency for Application Insights)
# ---------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.log_analytics_workspace.name_unique}-auth-poc"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---------------------------------------------------------------------------
# Application Insights
# FIX 2a: The resource itself is stable. We do NOT pass the connection_string
#          directly to the module (that would create perpetual drift).
# ---------------------------------------------------------------------------
resource "azurerm_application_insights" "this" {
  application_type    = "web"
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.application_insights.name_unique}-auth-poc"
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
}

# ---------------------------------------------------------------------------
# Key Vault — stores secrets so App Service references NAMES not VALUES
# ---------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  location                  = azurerm_resource_group.this.location
  name                      = module.naming.key_vault.name_unique
  resource_group_name       = azurerm_resource_group.this.name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true

  # Soft-delete protects secrets from accidental loss
  soft_delete_retention_days = 7
}

# Grant the deploying principal Key Vault Administrator so it can write secrets
resource "azurerm_role_assignment" "kv_admin" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
}

# ---------------------------------------------------------------------------
# FIX 2b: Store App Insights connection string in Key Vault.
#          lifecycle.ignore_changes = [value] means Terraform will NOT plan
#          an update if the instrumentation key rotates externally.
#          The App Service app setting is a STATIC Key Vault reference URI
#          that never changes — zero drift.
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "appinsights_connstr" {
  name         = "appinsights-connection-string"
  value        = azurerm_application_insights.this.connection_string
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.kv_admin]

  lifecycle {
    # DRIFT FIX: If the connection string rotates, do NOT force a web app
    # update. The Key Vault reference in the app setting already fetches
    # the current value at runtime automatically.
    ignore_changes = [value]
  }
}

# ---------------------------------------------------------------------------
# FIX 3: Store AAD client secret in Key Vault.
#         The App Service auth setting references the APP SETTING KEY NAME
#         "AAD_CLIENT_SECRET" — a static string that never changes.
#         Azure fetches the actual value from Key Vault at runtime.
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "aad_client_secret" {
  name         = "aad-client-secret"
  value        = var.aad_client_secret
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.kv_admin]

  lifecycle {
    # DRIFT FIX: Secret rotation outside Terraform does NOT cause drift.
    ignore_changes = [value]
  }
}

# ---------------------------------------------------------------------------
# App Service Plan (Windows P1v2)
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "P1v2"
}

# ---------------------------------------------------------------------------
# User Assigned Managed Identity for the Web App
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# Grant the web app identity permission to read Key Vault secrets
resource "azurerm_role_assignment" "webapp_kv_reader" {
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
}

# ---------------------------------------------------------------------------
# Main Web App — module version 0.15.1
#
# DRIFT-SAFE AUTH PATTERN SUMMARY:
#   1. application_insights_connection_string  → Key Vault reference (static URI)
#   2. auth_settings_v2.azure_active_directory → client_secret_setting_name
#      points to app setting key "AAD_CLIENT_SECRET" (static string, never changes)
#   3. login.token_store → ALL fields explicitly set so Azure cannot
#      auto-populate and cause a null→value diff on the next plan
# ---------------------------------------------------------------------------
module "avm_res_web_site" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.15.1"

  location                = azurerm_resource_group.this.location
  name                    = module.naming.app_service.name_unique
  resource_group_name     = azurerm_resource_group.this.name
  service_plan_resource_id = azurerm_service_plan.this.id
  os_type                 = "Windows"
  kind                    = "webapp"
  enable_telemetry        = var.enable_telemetry

  # -------------------------------------------------------------------------
  # FIX 2c: App Insights connection string is passed as a Key Vault reference.
  # The string "@Microsoft.KeyVault(SecretUri=...)" is STATIC — it does NOT
  # change when the instrumentation key rotates. No drift.
  # -------------------------------------------------------------------------
  app_settings = {
    # Key Vault reference — Azure resolves the actual value at runtime.
    # This string is IMMUTABLE after first deployment → zero drift.
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.appinsights_connstr.versionless_id})"

    # -----------------------------------------------------------------------
    # FIX 3b: The app setting VALUE is the STATIC Key Vault reference URI.
    # auth_settings_v2 refers to this setting by KEY NAME "AAD_CLIENT_SECRET".
    # Even if the secret value rotates in Key Vault, this string NEVER changes.
    # -----------------------------------------------------------------------
    "AAD_CLIENT_SECRET" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.aad_client_secret.versionless_id})"
  }

  # -------------------------------------------------------------------------
  # Managed Identity — required so the web app can read Key Vault secrets
  # -------------------------------------------------------------------------
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }

  # -------------------------------------------------------------------------
  # FIX 3c: auth_settings_v2 with Azure Active Directory
  #
  # CRITICAL DRIFT RULE: NEVER pass client_secret inline.
  # Use client_secret_setting_name = "AAD_CLIENT_SECRET" which is a pointer
  # to the app setting key above. This pointer is a STATIC STRING — it does
  # not change between runs, so Terraform sees no diff → no drift.
  #
  # FIX 4: login.token_store — ALL fields are explicitly set.
  # If you omit token_store entirely, Azure writes default values on first
  # deploy. On the next plan Terraform reads null from config but sees
  # actual values in state → perpetual update loop.
  # By being explicit, config and state always match → zero drift.
  # -------------------------------------------------------------------------
  auth_settings_v2 = {
    auth_enabled             = true
    redirect_to_provider     = "AzureActiveDirectory"
    require_authentication   = true
    require_https            = true
    runtime_version          = "~1"
    unauthenticated_client_action = "RedirectToLoginPage"

    identity_providers = {
      azure_active_directory = {
        enabled = true
        registration = {
          client_id = var.aad_client_id

          # DRIFT-SAFE: this is a static KEY NAME string, NOT the secret value.
          # Azure reads the actual secret from the app setting at runtime.
          client_secret_setting_name = "AAD_CLIENT_SECRET"

          # Construct the issuer URL from a variable — always deterministic.
          open_id_issuer = "https://login.microsoftonline.com/${var.aad_tenant_id}/v2.0"
        }
        validation = {
          # Explicitly list allowed audiences so Azure doesn't auto-populate
          # and create a null→value diff on next plan.
          allowed_audiences = [
            "api://${var.aad_client_id}"
          ]
        }
      }
    }

    # -----------------------------------------------------------------------
    # FIX 4: token_store — ALL fields explicitly provided.
    # -----------------------------------------------------------------------
    login = {
      token_store = {
        # Explicitly enable — if omitted, Azure sets it and plan shows diff.
        enabled = true

        # Explicitly set refresh hours — default is 72 but must be declared
        # or Terraform will see null vs 72 on next plan.
        token_refresh_extension_hours = 72
      }

      # Explicitly set nonce settings to match Azure defaults.
      # If omitted, Azure writes them and next plan shows drift.
      nonce = {
        nonce_expiration_interval = "00:05:00"
        validate_nonce            = true
      }

      preserve_url_fragments_for_logins = false
    }
  }

  public_network_access_enabled = true

  site_config = {
    # Use TLS 1.3 — highest minimum version
    minimum_tls_version = "1.3"
    ftps_state          = "FtpsOnly"
    always_on           = true
  }

  tags = {
    module          = "Azure/avm-res-web-site/azurerm"
    version         = "0.15.1"
    poc_purpose     = "auth-no-drift"
    drift_safe      = "true"
  }
}
