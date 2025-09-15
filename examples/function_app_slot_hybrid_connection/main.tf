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

resource "azurerm_windows_function_app" "example" {
  name                = "${module.naming.function_app.name_unique}-functionapp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  site_config {}

  tags = {
    example = "function_app_slot_hybrid_connection"
  }
}

resource "azurerm_windows_function_app_slot" "example" {
  name            = "staging"
  function_app_id = azurerm_windows_function_app.example.id

  storage_account_name = azurerm_storage_account.example.name

  site_config {}

  tags = {
    example = "function_app_slot_hybrid_connection"
  }
}

resource "azapi_resource" "function_app_slot_hybrid_connection" {
  type      = "Microsoft.Web/sites/slots/hybridConnectionNamespaces/relays@2023-01-01"
  name      = azurerm_windows_function_app_slot.example.name
  parent_id = "${azurerm_windows_function_app_slot.example.id}/hybridConnectionNamespaces/${azurerm_relay_namespace.example.name}"

  body = {
    properties = {
      relayArmUri  = azurerm_relay_hybrid_connection.example.id
      hostname     = "example.hostname"
      port         = 8081
      sendKeyName  = "RootManageSharedAccessKey"
      sendKeyValue = data.azapi_resource_action.relay_keys.output.primaryKey
    }
  }

  depends_on = [
    azurerm_windows_function_app_slot.example,
    data.azapi_resource_action.relay_keys
  ]
}

data "azapi_resource_action" "relay_keys" {
  type                   = "Microsoft.Relay/namespaces/authorizationRules@2021-11-01"
  resource_id            = "${azurerm_relay_namespace.example.id}/authorizationRules/RootManageSharedAccessKey"
  action                 = "listKeys"
  response_export_values = ["*"]
}
