## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.11.0"
  is_recommended = true
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

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body     = {}
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2024-04-01"
  body = {
    kind = "linux"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved = true
    }
  }
  tags = {
    app = "${module.naming.app_service.name_unique}-default"
  }
}

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-auto-heal"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

module "avm_res_web_site" {
  source = "../../"

  kind                     = "webapp"
  location                 = azapi_resource.resource_group.location
  name                     = "${module.naming.app_service.name_unique}-auto-heal"
  os_type                  = "Linux"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    workspace_resource_id = azapi_resource.log_analytics_workspace.id
  }
  auto_heal_setting = {
    setting_1 = {
      action = {
        action_type                    = "Recycle"
        minimum_process_execution_time = "00:01:00"
      }
      trigger = {
        requests = {
          request = {
            count    = 100
            interval = "00:00:30"
          }
        }
        status_code = {
          status_5000 = {
            count             = 5000
            interval          = "00:05:00"
            path              = "/HealthCheck"
            status_code_range = 500
            sub_status        = 0
          }
          status_6000 = {
            count             = 6000
            interval          = "00:05:00"
            path              = "/Get"
            status_code_range = 500
            sub_status        = 0
          }
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  site_config = {

  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
