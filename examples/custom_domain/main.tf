resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"
  body     = {}
  tags = {
    SecurityControl = "Ignore" # Useful for test environments
  }
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2025-03-01"
  body = {
    kind = "app"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved      = false
      zoneRedundant = true
    }
  }
  tags = {
    app = "${module.naming.function_app.name_unique}-custom-domain"
  }
}

resource "azapi_resource" "storage_account" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Storage/storageAccounts@2025-01-01"
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_ZRS"
    }
    properties = {
      networkAcls = {
        defaultAction = "Allow"
        bypass        = "AzureServices"
      }
    }
  }
}

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-custom-domain"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2025-02-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

resource "azapi_resource" "application_insights" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.application_insights.name_unique}-custom-domain"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Insights/components@2020-02-02"
  body = {
    kind = "web"
    properties = {
      Application_Type    = "web"
      WorkspaceResourceId = azapi_resource.log_analytics_workspace.id
    }
  }
  response_export_values = ["properties.ConnectionString", "properties.InstrumentationKey"]
}

# ---------------------------------------------------------------------------
# Hostnames bound by this example.
#
# `contoso.com` is intentionally a domain we do not own, so `terraform apply`
# will not succeed end-to-end (the directory is marked with `.e2eignore`
# for that reason). To run it for real, replace these with hostnames you
# control and import the matching PFX into the Key Vault under the name
# `key_vault_certificate_secret_name`.
# ---------------------------------------------------------------------------

locals {
  custom_hostname                   = "app.contoso.com"
  key_vault_certificate_secret_name = "app-contoso-com"
  qa_slot_custom_hostname           = "qa.contoso.com"
}

# ---------------------------------------------------------------------------
# Step 1 – DNS records
# ---------------------------------------------------------------------------
# DNS for `app.contoso.com` / `qa.contoso.com` is intentionally NOT managed
# here because we do not own the domain. In a real deployment, create a
# CNAME or `asuid` TXT record on your authoritative zone before applying.
# The required value can be read from
# `module.avm_res_web_site.custom_domain_verification_id`.

# ---------------------------------------------------------------------------
# Step 2 – Key Vault containing the certificate
# ---------------------------------------------------------------------------

resource "azapi_resource" "key_vault" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.key_vault.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.KeyVault/vaults@2024-11-01"
  body = {
    properties = {
      tenantId                     = data.azapi_client_config.current.tenant_id
      enableRbacAuthorization      = true
      enabledForDeployment         = false
      enabledForTemplateDeployment = false
      enabledForDiskEncryption     = false
      enableSoftDelete             = true
      softDeleteRetentionInDays    = 7
      sku = {
        family = "A"
        name   = "standard"
      }
      networkAcls = {
        defaultAction = "Allow"
        bypass        = "AzureServices"
      }
    }
  }
}

# Import the PFX manually before applying – see step 2 of the README:
#
#   az keyvault certificate import \
#     --vault-name <kv-name> \
#     --name <key_vault_certificate_secret_name> \
#     --file ./app.contoso.com.pfx \
#     --password <pfx-password>

# ---------------------------------------------------------------------------
# Step 3 – Grant the App Service first-party SP read access to the cert
# ---------------------------------------------------------------------------
# `abfa0a7c-a6b6-4736-8310-5855508787cd` is the well-known object ID of the
# `Microsoft Azure App Service` first-party service principal. The role
# `db79e9a7-68ee-4b58-9aeb-b90e7c24fcba` is `Key Vault Certificate User`.

resource "random_uuid" "kv_role_assignment" {}

resource "azapi_resource" "kv_role_assignment" {
  name      = random_uuid.kv_role_assignment.result
  parent_id = azapi_resource.key_vault.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/db79e9a7-68ee-4b58-9aeb-b90e7c24fcba"
      principalId      = "abfa0a7c-a6b6-4736-8310-5855508787cd"
      principalType    = "ServicePrincipal"
    }
  }
  ignore_null_property = true
}

# ---------------------------------------------------------------------------
# Step 4 / 5 – Materialise the certificate and bind hostnames via this module
# ---------------------------------------------------------------------------
# `certificates` declares a `Microsoft.Web/certificates` resource that pulls
# the secret out of the Key Vault provisioned in step 2. Each entry in
# `custom_domains` (on the main site or any slot) can then reference the
# certificate by `certificate_key` instead of by raw `thumbprint`, removing
# the need for callers to invoke the certificate submodule directly.

module "avm_res_web_site" {
  source = "../../"

  location                               = azapi_resource.resource_group.location
  name                                   = "${module.naming.function_app.name_unique}-default"
  parent_id                              = azapi_resource.resource_group.id
  service_plan_resource_id               = azapi_resource.service_plan.id
  application_insights_connection_string = azapi_resource.application_insights.output.properties.ConnectionString
  application_insights_key               = azapi_resource.application_insights.output.properties.InstrumentationKey
  certificates = {
    primary = {
      key_vault_id          = azapi_resource.key_vault.id
      key_vault_secret_name = local.key_vault_certificate_secret_name
    }
  }
  custom_domains = {
    primary = {
      hostname        = local.custom_hostname
      ssl_state       = "SniEnabled"
      certificate_key = "primary"
    }
  }
  deployment_slots = {
    qa = {
      name = "qa"
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
      custom_domains = {
        primary = {
          hostname        = local.qa_slot_custom_hostname
          ssl_state       = "SniEnabled"
          certificate_key = "primary"
        }
      }
    },
    dev = {
      name = "dev"
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
  }
  enable_telemetry              = var.enable_telemetry
  kind                          = "functionapp"
  os_type                       = "Windows"
  public_network_access_enabled = true
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "v8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_account_name       = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }

  depends_on = [azapi_resource.kv_role_assignment]
}
