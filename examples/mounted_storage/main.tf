## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.0"
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
  version = "0.4.2"
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
    app = module.naming.app_service.name_unique
  }
}

resource "azurerm_log_analytics_workspace" "example_production" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-production"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "example_development" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-development-env"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "content" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}

resource "azurerm_storage_share" "content" {
  name               = "app-content"
  quota              = 10
  storage_account_id = azurerm_storage_account.content.id
}

resource "azurerm_storage_share" "dev_content" {
  name               = "dev-content"
  quota              = 10
  storage_account_id = azurerm_storage_account.content.id
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "webapp"
  location = azurerm_resource_group.example.location
  name     = module.naming.app_service.name_unique
  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  }
  deployment_slots = {
    slot1 = {
      name = "development-env"
      site_config = {
        slot_application_insights_object_key = "development" # This is the key for the slot application insights mapping
        application_stack = {
          dotnet = {
            current_stack               = "dotnet"
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
      storage_shares_to_mount = {
        dev_content = {
          name         = "dev-content"
          account_name = azurerm_storage_account.content.name
          # access_key   = azurerm_storage_account.content.primary_access_key
          share_name = azurerm_storage_share.content.name
          mount_path = "/mounts/${azurerm_storage_share.dev_content.name}"
        }
      }

    }
  }
  enable_telemetry = var.enable_telemetry
  # Creates application insights for slot
  slot_application_insights = {
    development = {
      name                  = "${module.naming.application_insights.name_unique}-development-env"
      workspace_resource_id = azurerm_log_analytics_workspace.example_development.id
      inherit_tags          = true
    }
  }
  slots_storage_shares_to_mount_sensitive_values = {
    dev_content = azurerm_storage_account.content.primary_access_key
  }
  storage_shares_to_mount = {
    content = {
      name         = "content"
      account_name = azurerm_storage_account.content.name
      access_key   = azurerm_storage_account.content.primary_access_key
      share_name   = azurerm_storage_share.content.name
      mount_path   = "/mounts/${azurerm_storage_share.content.name}"
    }
  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
