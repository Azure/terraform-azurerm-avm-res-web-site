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

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.10.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-slots"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "webapp"
  os_type = "Linux"

  site_config = {
    # auto_heal_enabled = true
    # auto_heal_enabled = false # This will throw a module and provider error.
    auto_heal_enabled = null # `auto_heal_setting` cannot be set if `auto_heal_enabled` is set to `null`. `null` is the default value for `auto_heal_enabled`

  }
  auto_heal_setting = { # auto_heal_setting should only be specified if auto_heal_enabled is set to `true`
    # setting_1 = {
    #   action = {
    #     action_type                    = "Recycle"
    #     minimum_process_execution_time = "00:01:00"
    #   }
    #   trigger = {
    #     requests = {
    #       count    = 100
    #       interval = "00:00:30"
    #     }
    #     status_code = {
    #       status_5000 = {
    #         count             = 5000
    #         interval          = "00:05:00"
    #         path              = "/HealthCheck"
    #         status_code_range = 500
    #         sub_status        = 0
    #       }
    #       status_6000 = {
    #         count             = 6000
    #         interval          = "00:05:00"
    #         path              = "/Get"
    #         status_code_range = 500
    #         sub_status        = 0
    #       }
    #     }
    #   }
    # }
  }

  # Creates a new app service plan
  create_service_plan = true
  new_service_plan = {
    sku_name               = var.sku_for_testing
    zone_balancing_enabled = var.redundancy_for_testing
  }
}
