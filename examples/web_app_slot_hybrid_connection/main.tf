# Web App Slot Hybrid Connection Basic Example

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.0"
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

# Create a Relay Namespace
resource "azurerm_relay_namespace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.servicebus_namespace.name_unique}-relay"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Standard"
}

# Create a Hybrid Connection in the Relay namespace
resource "azurerm_relay_hybrid_connection" "example" {
  name                          = "example-hybrid-connection"
  relay_namespace_name          = azurerm_relay_namespace.example.name
  resource_group_name           = azurerm_resource_group.example.name
  requires_client_authorization = true
}

# Create a Windows Web App
resource "azurerm_windows_web_app" "example" {
  name                = "${module.naming.app_service.name_unique}-webapp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}

  tags = {
    example = "web_app_slot_hybrid_connection"
  }
}

# Create a Web App Slot
resource "azurerm_windows_web_app_slot" "example" {
  name           = "staging"
  app_service_id = azurerm_windows_web_app.example.id

  site_config {}

  tags = {
    example = "web_app_slot_hybrid_connection"
  }
}

# Create Web App Slot Hybrid Connection using azapi
resource "azapi_resource" "web_app_slot_hybrid_connection" {
  type      = "Microsoft.Web/sites/slots/hybridConnectionNamespaces/relays@2023-01-01"
  name      = azurerm_windows_web_app_slot.example.name
  parent_id = "${azurerm_windows_web_app_slot.example.id}/hybridConnectionNamespaces/${azurerm_relay_namespace.example.name}"

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
    azurerm_windows_web_app_slot.example,
    data.azapi_resource_action.relay_keys
  ]
}

# Get relay namespace keys
data "azapi_resource_action" "relay_keys" {
  type                   = "Microsoft.Relay/namespaces/authorizationRules@2021-11-01"
  resource_id            = "${azurerm_relay_namespace.example.id}/authorizationRules/RootManageSharedAccessKey"
  action                 = "listKeys"
  response_export_values = ["*"]
}
