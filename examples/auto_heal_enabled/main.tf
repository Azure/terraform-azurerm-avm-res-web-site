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
}

module "avm_res_web_serverfarm" {
  source  = "Azure/avm_res_web_serverfarm/azurerm"
  version = "0.2.0"

  enable_telemetry = var.enable_telemetry

  name                = module.naming.app_service_plan.name_unique
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location
  os_type             = "Linux"

}

module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm_res_web_site/azurerm"
  # version = "0.11.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-auto-heal"
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location

  kind = "webapp"

  os_type                  = module.avm_res_web_serverfarm.resource.os_type
  service_plan_resource_id = module.avm_res_web_serverfarm.resource_id

  site_config = {
    auto_heal_enabled = true # `auto_heal_enabled` deprecated in azurerm 4.x
  }
  auto_heal_setting = { # auto_heal_setting should only be specified if auto_heal_enabled is set to `true`
    setting_1 = {
      action = {
        action_type                    = "Recycle"
        minimum_process_execution_time = "00:01:00"
      }
      trigger = {
        requests = {
          count    = 100
          interval = "00:00:30"
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
}
