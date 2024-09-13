## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
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

module "avm_res_resources_resourcegroup" {
  source  = "Azure/avm_res_resources_resourcegroup/azurerm"
  version = "0.1.0"

  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  tags = {
    module  = "Azure/avm_res_resources_resourcegroup/azurerm"
    version = "0.1.0"
  }
}

module "avm_res_web_serverfarm" {
  source  = "Azure/avm_res_web_serverfarm/azurerm"
  version = "0.2.0"

  enable_telemetry = var.enable_telemetry

  name                = module.naming.app_service_plan.name_unique
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location
  os_type             = "Linux"

  tags = {
    module  = "Azure/avm_res_web_serverfarm/azurerm"
    version = "0.2.0"
  }
}

# This is the module call
module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.11.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.app_service.name_unique}-logs"
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location

  kind                     = "webapp"
  os_type                  = module.avm_res_web_serverfarm.resource.os_type
  service_plan_resource_id = module.avm_res_web_serverfarm.resource_id

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
