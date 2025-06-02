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

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-container"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "P1v2"
  tags = {
    app = "${module.naming.function_app.name_unique}-container"
  }
  zone_balancing_enabled = true
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "webapp"
  location = azurerm_resource_group.example.location
  name     = "${module.naming.function_app.name_unique}-container"
  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  app_settings = {

  }
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
  }
  enable_telemetry = var.enable_telemetry
  site_config = {
    application_stack = {
      docker = {
        docker_image_name   = "dotnet/aspnet:8.0"
        docker_registry_url = "https://mcr.microsoft.com"
      }
    }
  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.16.4"
  }
}
