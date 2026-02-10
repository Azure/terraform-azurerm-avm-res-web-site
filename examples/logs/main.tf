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
      name = "S1"
    }
    properties = {
      reserved = true
    }
  }
  tags = {
    app = "${module.naming.app_service.name_unique}-logs"
  }
}

resource "azapi_resource" "log_analytics_workspace_staging" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-staging"
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

resource "azapi_resource" "log_analytics_workspace_development" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-development"
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
  source = "../.."

  kind                     = "webapp"
  location                 = azapi_resource.resource_group.location
  name                     = "${module.naming.app_service.name_unique}-logs"
  os_type                  = "Linux"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    workspace_resource_id = azapi_resource.log_analytics_workspace_production.id
  }
  deployment_slots = {
    slot1 = {
      name                                           = "development-logs"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        slot_application_insights_object_key = "development" # This is the key for the slot application insights mapping
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
      logs = {
        app_service_logs = {
          application_logs = {
            file_system_level = {
              file_system_level = "Warning"
            }
          }
          http_logs = {
            file_system_level = {
              file_system = {
                retention_in_days = 7
                retention_in_mb   = 35
              }
            }
          }
        }
      }
    }
    slot2 = {
      name                                           = "staging-logs"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        application_insights_connection_string = azapi_resource.application_insights_staging.output.properties.ConnectionString
        application_insights_key               = azapi_resource.application_insights_staging.output.properties.InstrumentationKey
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }

      logs = {
        app_service_logs = {
          application_logs = {
            file_system_level = {
              file_system_level = "Off"
            }
          }
          http_logs = {
            file_system_level = {
              file_system = {
                retention_in_days = 7
                retention_in_mb   = 35
              }
            }
          }
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  logs = {
    app_service_logs = {
      # Added validation to ensure that logs object is configured.
      # If file_system_level is set to "Off", then http_logs will have no effect
      # logs set in `logs`
      application_logs = {
        file_system_level = {
          file_system_level = "Off"
        }
      }
      # Added validation to ensure that is http_logs is configured, application_logs must also be configured.
      http_logs = {
        file_system_level = {
          file_system = {
            retention_in_days = 7
            retention_in_mb   = 35
          }
        }
      }
    }
  }
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
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
    version = "0.17.2"
  }
}
