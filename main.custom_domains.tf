resource "azapi_resource" "hostname_binding" {
  for_each = { for k, v in var.custom_domains : k => v if !v.slot_as_target }

  name      = each.value.hostname
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/hostNameBindings@2024-04-01"
  body = {
    properties = {
      sslState   = each.value.ssl_state
      thumbprint = each.value.thumbprint_value
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slot_hostname_binding" {
  for_each = { for k, v in var.custom_domains : k => v if v.slot_as_target }

  name      = each.value.hostname
  parent_id = azapi_resource.slot[each.value.app_service_slot_key].id
  type      = "Microsoft.Web/sites/slots/hostNameBindings@2024-04-01"
  body = {
    properties = {
      sslState   = each.value.ssl_state
      thumbprint = each.value.thumbprint_value
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
