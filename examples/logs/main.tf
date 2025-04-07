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
    app = "${module.naming.function_app.name_unique}-logs"
  }
}

# This is the module call
module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.16.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-logs"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind = "webapp"

  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id

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
      http_logs = {
        config1 = {
          file_system = {
            retention_in_days = 30
            retention_in_mb   = 35
          }
        }
      }
      application_logs = {
        config1 = {
          file_system_level = "Warning"
        }
      }
    }
  }

  deployment_slots = {
    slot1 = {
      name = "staging"
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
          http_logs = {
            config1 = {
              file_system = {
                retention_in_days = 30
                retention_in_mb   = 35
              }
            }
          }
          application_logs = {
            config1 = {
              file_system_level = "Warning"
            }
          }
        }
      }
    }
  }
}
