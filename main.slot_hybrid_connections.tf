# Function App Slot Hybrid Connections
resource "azapi_resource" "function_app_slot_hybrid_connection" {
  for_each = var.kind == "functionapp" && !var.function_app_uses_fc1 ? var.function_app_slot_hybrid_connections : {}

  type      = "Microsoft.Web/sites/slots/hybridConnectionNamespaces/relays@2023-01-01"
  name      = basename(each.value.relay_id)
  parent_id = "${var.os_type == "Windows" ? azurerm_windows_function_app_slot.this[each.value.slot_key].id : azurerm_linux_function_app_slot.this[each.value.slot_key].id}/hybridConnectionNamespaces/${split("/", each.value.relay_id)[8]}"

  body = jsonencode({
    properties = {
      relayArmUri = each.value.relay_id
      hostname    = each.value.hostname
      port        = each.value.port
      sendKeyName = each.value.send_key_name
    }
  })

  response_export_values = ["*"]

  depends_on = [
    azurerm_linux_function_app_slot.this,
    azurerm_windows_function_app_slot.this
  ]

  lifecycle {
    ignore_changes = [
      body
    ]
  }

  tags = var.all_child_resources_inherit_tags ? merge(var.tags, local.avm_azapi_headers) : local.avm_azapi_headers
}

# Web App Slot Hybrid Connections
resource "azapi_resource" "web_app_slot_hybrid_connection" {
  for_each = var.kind == "webapp" ? var.web_app_slot_hybrid_connections : {}

  type      = "Microsoft.Web/sites/slots/hybridConnectionNamespaces/relays@2023-01-01"
  name      = basename(each.value.relay_id)
  parent_id = "${var.os_type == "Windows" ? azurerm_windows_web_app_slot.this[each.value.slot_key].id : azurerm_linux_web_app_slot.this[each.value.slot_key].id}/hybridConnectionNamespaces/${split("/", each.value.relay_id)[8]}"

  body = jsonencode({
    properties = {
      relayArmUri = each.value.relay_id
      hostname    = each.value.hostname
      port        = each.value.port
      sendKeyName = each.value.send_key_name
    }
  })

  response_export_values = ["*"]

  depends_on = [
    azurerm_linux_web_app_slot.this,
    azurerm_windows_web_app_slot.this
  ]

  lifecycle {
    ignore_changes = [
      body
    ]
  }

  tags = var.all_child_resources_inherit_tags ? merge(var.tags, local.avm_azapi_headers) : local.avm_azapi_headers
}
