resource "azurerm_app_service_custom_hostname_binding" "this" {
  for_each = var.custom_domains

  app_service_name    = each.value.app_service_name
  hostname            = each.value.hostname
  resource_group_name = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  ssl_state           = each.value.ssl_state
  thumbprint          = each.value.thumbprint
}