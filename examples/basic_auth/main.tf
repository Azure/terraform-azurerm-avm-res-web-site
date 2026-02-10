module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.11.0"

  is_recommended = true
}

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
      reserved = false
    }
  }
  tags = {
    app = "${module.naming.function_app.name_unique}-basic-auth"
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

data "azapi_resource_action" "storage_keys" {
  action                 = "listKeys"
  method                 = "POST"
  resource_id            = azapi_resource.storage_account.id
  type                   = "Microsoft.Storage/storageAccounts@2025-01-01"
  response_export_values = ["keys"]
}

module "avm_res_web_site" {
  source = "../../"

  location                 = azapi_resource.resource_group.location
  name                     = "${module.naming.function_app.name_unique}-basic-auth"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  auth_settings = {
    sso = {
      enabled = true
      active_directory = {
        aad = {
          client_id                  = "000000-000000-000000-000000"
          client_secret_setting_name = "SSO_CLIENT_SECRET"
        }
      }
    }
  }
  auth_settings_v2 = {
    setting1 = {
      auth_enabled     = true
      default_provider = "AzureActiveDirectory"

      active_directory_v2 = {
        aad1 = {
          client_id            = "<>"
          tenant_auth_endpoint = "https://login.microsoftonline.com/{}/v2.0/"
        }
      }
      login = {
        login1 = {
          token_store_enabled = true
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  kind             = "functionapp"
  os_type          = "Windows"
  site_config = {
    ftps_state = "FtpsOnly"
  }
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_account_name       = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
