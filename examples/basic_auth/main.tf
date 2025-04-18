## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.8.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "P1v2"
  tags = {
    app = "${module.naming.function_app.name_unique}-basic-auth"
  }
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.16.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-basic-auth"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind = "functionapp"

  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id

  # Uses an existing storage account
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  site_config = {
    ftps_state = "FtpsOnly"
  }

  # May require additional configuration for the authentication settings by use of App Registration

  # /*

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

  # */

}
