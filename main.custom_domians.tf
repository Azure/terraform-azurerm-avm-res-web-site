resource "azurerm_app_service_certificate" "this" {
  for_each = { for cert, cert_values in var.custom_domains : cert => cert_values if cert_values.create_certificate }

  location            = each.value.certificate_location
  name                = each.value.certificate_name
  resource_group_name = each.value.resource_group_name
  app_service_plan_id = each.value.app_service_plan_resource_id
  key_vault_id        = each.value.key_vault_id
  key_vault_secret_id = each.value.key_vault_secret_id
  password            = each.value.pfx_password
  pfx_blob            = each.value.pfx_blob
  tags                = each.value.inherit_tags ? merge(each.value.tags, var.tags) : each.value.tags
}

resource "azurerm_dns_cname_record" "this" {
  for_each = { for cname, cname_values in var.custom_domains : cname => cname_values if cname_values.create_cname_records }

  name                = each.value.cname_name
  resource_group_name = coalesce(each.value.zone_resource_group_name, var.resource_group_name)
  ttl                 = each.value.ttl
  zone_name           = each.value.cname_zone_name
  record              = each.value.cname_record
  tags                = each.value.inherit_tags ? merge(each.value.tags, var.tags) : each.value.tags
  target_resource_id  = each.value.cname_target_resource_id

  depends_on = [azurerm_windows_function_app.this, azurerm_windows_function_app_slot.this, azurerm_linux_function_app.this, azurerm_linux_function_app_slot.this]
}

resource "azurerm_dns_txt_record" "this" {
  for_each = { for txt, txt_values in var.custom_domains : txt => txt_values if txt_values.create_txt_records }

  name                = each.value.txt_name
  resource_group_name = coalesce(each.value.zone_resource_group_name, var.resource_group_name)
  ttl                 = each.value.ttl
  zone_name           = each.value.txt_zone_name
  tags                = each.value.inherit_tags ? merge(each.value.tags, var.tags) : each.value.tags

  dynamic "record" {
    for_each = each.value.txt_records

    content {
      value = coalesce(record.value.value, local.custom_domain_verification_id)
    }
  }

  depends_on = [azurerm_windows_function_app.this, azurerm_windows_function_app_slot.this, azurerm_linux_function_app.this, azurerm_linux_function_app_slot.this]
}

resource "azurerm_app_service_custom_hostname_binding" "this" {
  for_each = { for binding, domains in var.custom_domains : binding => domains if !domains.slot_as_target }

  app_service_name    = coalesce(each.value.app_service_name, "${var.name}-asp")
  hostname            = each.value.hostname
  resource_group_name = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  ssl_state           = each.value.ssl_state
  thumbprint          = azurerm_app_service_certificate.this[each.value.thumbprint_key].thumbprint

  depends_on = [azurerm_windows_function_app.this, azurerm_windows_function_app_slot.this, azurerm_linux_function_app.this, azurerm_linux_function_app_slot.this, azurerm_dns_txt_record.this, azurerm_dns_cname_record.this]
}

resource "azurerm_app_service_slot_custom_hostname_binding" "slot" {
  for_each = { for binding, domains in var.custom_domains : binding => domains if domains.slot_as_target }

  app_service_slot_id = var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app_slot.this[each.value.app_service_slot_key].id : azurerm_linux_function_app_slot.this[each.value.app_service_slot_key].id) : (var.os_type == "Windows" ? azurerm_windows_web_app_slot.this[each.value.app_service_slot_key].id : azurerm_linux_web_app_slot.this[each.value.app_service_slot_key].id)
  hostname            = each.value.hostname
  ssl_state           = each.value.ssl_state
  thumbprint          = azurerm_app_service_certificate.this[each.value.thumbprint_key].thumbprint

  depends_on = [
    azurerm_windows_function_app.this, azurerm_windows_function_app_slot.this,
    azurerm_windows_web_app.this, azurerm_windows_web_app_slot.this,
    azurerm_linux_function_app.this, azurerm_linux_function_app_slot.this,
    azurerm_linux_web_app.this, azurerm_linux_web_app_slot.this,
    azurerm_dns_txt_record.this, azurerm_dns_cname_record.this
  ]
}