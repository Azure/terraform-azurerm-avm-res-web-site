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
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "S1"
  tags = {
    app = "${module.naming.app_service.name_unique}-app-stack"
  }
}

resource "azurerm_application_insights" "example_staging" {
  application_type    = "web"
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.application_insights.name_unique}-staging"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example_staging.id
}

resource "azurerm_log_analytics_workspace" "example_production" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-production"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "example_staging" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-staging"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "example_development" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-development"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

# This is the module call
module "avm_res_web_site" {
  source = "../.."

  kind                     = "webapp"
  location                 = azurerm_resource_group.example.location
  name                     = "${module.naming.app_service.name_unique}-app-stack"
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  }
  deployment_slots = {
    slot1 = {
      name                                           = "development-app-stack"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        slot_application_insights_object_key = "development" # This is the key for the slot application insights mapping
        application_stack = {
          python = {
            python_version = "3.13"
          }
        }
      }
    }
    slot2 = {
      name                                           = "staging-app-stack"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        # Uses existing application insights
        application_insights_connection_string = nonsensitive(azurerm_application_insights.example_staging.connection_string)
        application_insights_key               = nonsensitive(azurerm_application_insights.example_staging.instrumentation_key)
        application_stack = {
          python = {
            python_version = "3.13"
          }
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  site_config = {
    application_stack = {
      python = {
        python_version = "3.13"
      }
    }
  }
  # Creates application insights for slot
  slot_application_insights = {
    development = {
      name                  = "${module.naming.application_insights.name_unique}-development"
      workspace_resource_id = azurerm_log_analytics_workspace.example_development.id
      inherit_tags          = true
    }
  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.19.3"
  }
}
