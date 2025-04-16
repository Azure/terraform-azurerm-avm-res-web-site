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
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "S1"
  tags = {
    app = "${module.naming.function_app.name_unique}-logs"
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

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.16.3"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-logs"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind = "webapp"

  os_type                  = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id

  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
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
        # Uses existing application insights
        application_insights_connection_string = nonsensitive(azurerm_application_insights.example_staging.connection_string)
        application_insights_key               = nonsensitive(azurerm_application_insights.example_staging.instrumentation_key)
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

  # Creates application insights for slot
  slot_application_insights = {
    development = {
      name                  = "${module.naming.application_insights.name_unique}-development"
      workspace_resource_id = azurerm_log_analytics_workspace.example_development.id
      inherit_tags          = true
    }
  }
}
