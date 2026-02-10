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
    kind = "linux"
    sku = {
      name = "S1"
    }
    properties = {
      reserved = true
    }
  }
  tags = {
    app = "${module.naming.app_service.name_unique}-app-stack"
  }
}

resource "azapi_resource" "log_analytics_workspace_staging" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-staging"
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

resource "azapi_resource" "application_insights_staging" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.application_insights.name_unique}-staging"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Insights/components@2020-02-02"
  body = {
    kind = "web"
    properties = {
      Application_Type    = "web"
      WorkspaceResourceId = azapi_resource.log_analytics_workspace_staging.id
    }
  }
  response_export_values = ["properties.ConnectionString", "properties.InstrumentationKey"]
}

resource "azapi_resource" "log_analytics_workspace_production" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-production"
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

resource "azapi_resource" "log_analytics_workspace_development" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-development"
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

module "avm_res_web_site" {
  source = "../.."

  kind                     = "webapp"
  location                 = azapi_resource.resource_group.location
  name                     = "${module.naming.app_service.name_unique}-app-stack"
  os_type                  = "Linux"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    workspace_resource_id = azapi_resource.log_analytics_workspace_production.id
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
        application_insights_connection_string = azapi_resource.application_insights_staging.output.properties.ConnectionString
        application_insights_key               = azapi_resource.application_insights_staging.output.properties.InstrumentationKey
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
  slot_application_insights = {
    development = {
      name                  = "${module.naming.application_insights.name_unique}-development"
      workspace_resource_id = azapi_resource.log_analytics_workspace_development.id
      inherit_tags          = true
    }
  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.19.3"
  }
}
