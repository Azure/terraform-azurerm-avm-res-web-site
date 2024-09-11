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

resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# This is the module call
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.10.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.app_service.name_unique}-windows"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "webapp"
  os_type = "Windows"

  create_service_plan = true
  new_service_plan = {
    sku_name               = var.sku_for_testing
    zone_balancing_enabled = var.redundancy_for_testing
  }

  site_config = {
    application_stack = {
      dotnet = {
        current_stack  = "dotnet"
        dotnet_version = "v8.0"
      }
    }
  }

}
