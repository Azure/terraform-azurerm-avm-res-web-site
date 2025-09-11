# Get relay namespace keys for function app slots
data "azapi_resource_action" "function_app_slot_relay_keys" {
  for_each = var.kind == "functionapp" ? var.function_app_slot_hybrid_connections : {}

  type                   = "Microsoft.Relay/namespaces/authorizationRules@2021-11-01"
  resource_id            = "${substr(each.value.relay_id, 0, strrindex(each.value.relay_id, "/hybridConnections"))}/authorizationRules/${each.value.send_key_name}"
  action                 = "listKeys"
  response_export_values = ["*"]
}

resource "azapi_resource" "function_app_slot_hybrid_connection" {
  for_each = var.kind == "functionapp" ? var.function_app_slot_hybrid_connections : {}

  type      = "Microsoft.Web/sites/slots/hybridConnectionNamespaces/relays@2023-01-01"
  name      = each.value.name
  parent_id = "${each.value.function_app_id}/hybridConnectionNamespaces/${split("/", each.value.relay_id)[8]}"

  body = {
    properties = {
      relayArmUri  = each.value.relay_id
      hostname     = each.value.hostname
      port         = each.value.port
      sendKeyName  = each.value.send_key_name
      sendKeyValue = each.value.send_key_value != null ? each.value.send_key_value : data.azapi_resource_action.function_app_slot_relay_keys[each.key].output.primaryKey
    }
  }

  depends_on = [
    azurerm_linux_function_app_slot.this,
    azurerm_windows_function_app_slot.this,
    data.azapi_resource_action.function_app_slot_relay_keys
  ]

  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Get relay namespace keys for web app slots
data "azapi_resource_action" "web_app_slot_relay_keys" {
  for_each = var.kind == "webapp" ? var.web_app_slot_hybrid_connections : {}

  type                   = "Microsoft.Relay/namespaces/authorizationRules@2021-11-01"
  resource_id            = "${substr(each.value.relay_id, 0, strrindex(each.value.relay_id, "/hybridConnections"))}/authorizationRules/${each.value.send_key_name}"
  action                 = "listKeys"
  response_export_values = ["*"]
}

resource "azapi_resource" "web_app_slot_hybrid_connection" {
  for_each = var.kind == "webapp" ? var.web_app_slot_hybrid_connections : {}

  type      = "Microsoft.Web/sites/slots/hybridConnectionNamespaces/relays@2023-01-01"
  name      = each.value.name
  parent_id = "${each.value.web_app_id}/hybridConnectionNamespaces/${split("/", each.value.relay_id)[8]}"

  body = {
    properties = {
      relayArmUri  = each.value.relay_id
      hostname     = each.value.hostname
      port         = each.value.port
      sendKeyName  = each.value.send_key_name
      sendKeyValue = each.value.send_key_value != null ? each.value.send_key_value : data.azapi_resource_action.web_app_slot_relay_keys[each.key].output.primaryKey
    }
  }

  depends_on = [
    azurerm_linux_web_app_slot.this,
    azurerm_windows_web_app_slot.this,
    data.azapi_resource_action.web_app_slot_relay_keys
  ]

  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
