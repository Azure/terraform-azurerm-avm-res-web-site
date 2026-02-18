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
    kind = "linux"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved      = true
      zoneRedundant = true
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
  name      = "${module.naming.application_insights.name_unique}-auto-heal"
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

module "avm_res_web_site" {
  source = "../../"

  location                               = azapi_resource.resource_group.location
  name                                   = "${module.naming.app_service.name_unique}-auto-heal"
  parent_id                              = azapi_resource.resource_group.id
  service_plan_resource_id               = azapi_resource.service_plan.id
  application_insights_connection_string = azapi_resource.application_insights.output.properties.ConnectionString
  application_insights_key               = azapi_resource.application_insights.output.properties.InstrumentationKey
  enable_telemetry                       = var.enable_telemetry
  kind                                   = "webapp"
  os_type                                = "Linux"
  public_network_access_enabled          = true
  site_config = {
    auto_heal_enabled = true
    auto_heal_rules = {
      actions = {
        action_type                = "Recycle"
        min_process_execution_time = "00:01:00"
      }
      triggers = {
        requests = {
          count         = 100
          time_interval = "00:00:30"
        }
        status_codes = [
          {
            count         = 5000
            time_interval = "00:05:00"
            path          = "/HealthCheck"
            status        = 500
            sub_status    = 0
          },
          {
            count         = 6000
            time_interval = "00:05:00"
            path          = "/Get"
            status        = 500
            sub_status    = 0
          },
        ]
      }
    }
  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
