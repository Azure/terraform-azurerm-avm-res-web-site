module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.0"
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
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
  sku_name            = "S1"
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name
}

resource "azurerm_relay_namespace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.servicebus_namespace.name_unique}-relay"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Standard"
}

resource "azurerm_relay_hybrid_connection" "example" {
  name                          = "example-hybrid-connection"
  relay_namespace_name          = azurerm_relay_namespace.example.name
  resource_group_name           = azurerm_resource_group.example.name
  requires_client_authorization = true
}

module "function_app" {
  source = "../.."

  kind                     = "functionapp"
  location                 = azurerm_resource_group.example.location
  name                     = "${module.naming.function_app.name_unique}-functionapp"
  os_type                  = "Windows"
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  deployment_slots = {
    staging = {
      name = "staging"
    }
  }
  function_app_slot_hybrid_connections = {
    example = {
      name            = azurerm_relay_hybrid_connection.example.name
      function_app_id = module.function_app.function_app_deployment_slots["staging"].id
      relay_id        = azurerm_relay_hybrid_connection.example.id
      hostname        = "example.hostname"
      port            = 8081
      send_key_name   = "RootManageSharedAccessKey"
    }
  }
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  storage_account_name       = azurerm_storage_account.example.name
}
