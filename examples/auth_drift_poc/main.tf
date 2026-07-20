# POC: Authentication WITHOUT Token Drift
# Module: Azure/avm-res-web-site/azurerm version = "0.15.1"
#
# DRIFT PREVENTION PATTERNS:
# 1. random_integer with keepers - prevents region-induced recreation
# 2. AAD client secret via client_secret_setting_name (key name, not value)
# 3. Key Vault secret with ignore_changes - prevents drift on secret rotation
# 4. token_store - all fields explicitly set to prevent null->value diffs
# =============================================================================

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0

  # KEEPERS: Prevents regeneration on unrelated changes
  keepers = {
    regions_fingerprint = join(",", local.azure_regions)
  }
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# Resource Group
resource "azurerm_resource_group" "this" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# App Service Plan
resource "azurerm_service_plan" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "P1v2"
}

# Key Vault for secrets (prevents secret drift)
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  location                  = azurerm_resource_group.this.location
  name                      = module.naming.key_vault.name_unique
  resource_group_name       = azurerm_resource_group.this.name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# Grant Key Vault access to managed identity
resource "azurerm_role_assignment" "kv_reader" {
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
}

# Grant Key Vault admin access for initial secret creation
resource "azurerm_role_assignment" "kv_admin" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
}

# Store AAD client secret in Key Vault with ignore_changes
resource "azurerm_key_vault_secret" "aad_client_secret" {
  name         = "aad-client-secret"
  value        = var.aad_client_secret
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.kv_admin]

  lifecycle {
    ignore_changes = [value]
  }
}

# App Service with drift-safe authentication
module "avm_res_web_site" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.15.1"

  location                 = azurerm_resource_group.this.location
  name                     = module.naming.app_service.name_unique
  resource_group_name      = azurerm_resource_group.this.name
  service_plan_resource_id = azurerm_service_plan.this.id
  os_type                  = "Windows"
  kind                     = "webapp"
  enable_telemetry         = var.enable_telemetry

  # App Settings with Key Vault references
  app_settings = {
    # Key Vault reference for AAD secret - static string
    "AAD_CLIENT_SECRET" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.aad_client_secret.versionless_id})"
  }

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }

  # DRIFT-SAFE AUTH SETTINGS V2
  auth_settings_v2 = {
    auth_enabled           = true
    redirect_to_provider   = "AzureActiveDirectory"
    require_authentication = true
    require_https          = true
    runtime_version        = "~1"

    identity_providers = {
      azure_active_directory = {
        enabled = true
        registration = {
          client_id = var.aad_client_id

          # DRIFT FIX: Points to app setting KEY NAME (static), not the secret value
          client_secret_setting_name = "AAD_CLIENT_SECRET"

          open_id_issuer = "https://login.microsoftonline.com/${var.aad_tenant_id}/v2.0"
        }
        validation = {
          allowed_audiences = [
            "api://${var.aad_client_id}"
          ]
        }
      }
    }

    # DRIFT FIX: Explicitly set ALL token_store fields
    login = {
      token_store = {
        enabled                       = true
        token_refresh_extension_hours = 72
      }
    }
  }

  public_network_access_enabled = true

  site_config = {
    minimum_tls_version = "1.3"
    ftps_state          = "FtpsOnly"
    always_on           = true
  }
}