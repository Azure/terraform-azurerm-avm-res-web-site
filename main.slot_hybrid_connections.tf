data "azapi_resource_action" "function_app_slot_relay_namespace_keys" {
  for_each = var.kind == "functionapp" ? var.function_app_slot_hybrid_connections : {}

  type                   = "Microsoft.Relay/namespaces/authorizationRules@2021-11-01"
  resource_id            = "${join("/", slice(split("/", each.value.relay_id), 0, 9))}/authorizationRules/${each.value.send_key_name}"
  action                 = "listKeys"
  response_export_values = ["*"]
}

data "azapi_resource_action" "function_app_slot_relay_hybrid_connection_keys" {
  for_each = var.kind == "functionapp" && length(var.function_app_slot_hybrid_connections) > 0 ? {
    for key, value in var.function_app_slot_hybrid_connections :
    key => value
    if value.send_key_name != "RootManageSharedAccessKey"
  } : {}

  type                   = "Microsoft.Relay/namespaces/hybridConnections/authorizationRules@2021-11-01"
  resource_id            = "${each.value.relay_id}/authorizationRules/${each.value.send_key_name}"
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
      sendKeyValue = local.function_app_slot_send_key_values[each.key]
    }
  }

  depends_on = [
    azurerm_linux_function_app_slot.this,
    azurerm_windows_function_app_slot.this
  ]

  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

data "azapi_resource_action" "web_app_slot_relay_namespace_keys" {
  for_each = var.kind == "webapp" ? var.web_app_slot_hybrid_connections : {}

  type                   = "Microsoft.Relay/namespaces/authorizationRules@2021-11-01"
  resource_id            = "${join("/", slice(split("/", each.value.relay_id), 0, 9))}/authorizationRules/${each.value.send_key_name}"
  action                 = "listKeys"
  response_export_values = ["*"]
}

data "azapi_resource_action" "web_app_slot_relay_hybrid_connection_keys" {
  for_each = var.kind == "webapp" && length(var.web_app_slot_hybrid_connections) > 0 ? {
    for key, value in var.web_app_slot_hybrid_connections :
    key => value
    if value.send_key_name != "RootManageSharedAccessKey"
  } : {}

  type                   = "Microsoft.Relay/namespaces/hybridConnections/authorizationRules@2021-11-01"
  resource_id            = "${each.value.relay_id}/authorizationRules/${each.value.send_key_name}"
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
      sendKeyValue = local.web_app_slot_send_key_values[each.key]
    }
  }

  depends_on = [
    azurerm_linux_web_app_slot.this,
    azurerm_windows_web_app_slot.this
  ]

  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
