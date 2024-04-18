resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id)) : null
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    azurerm_linux_function_app.this,
    azurerm_windows_function_app.this,
    azurerm_private_endpoint.this,
    azurerm_role_assignment.this,
    azurerm_monitor_diagnostic_setting.this
  ]
}

resource "azurerm_management_lock" "pe" {
  for_each = { for private_endpoint, pe_values in var.private_endpoints : private_endpoint => pe_values if(((var.all_child_resources_inherit_lock || var.private_endpoints_inherit_lock) && var.lock != null) || (pe_values.lock != null)) }

  lock_level = (var.all_child_resources_inherit_lock || var.private_endpoints_inherit_lock) ? var.lock.kind : each.value.lock.kind
  name       = each.value.lock != null ? each.value.lock.name : (each.value.name != null ? "lock-${each.value.name}" : "lock-pe-${var.name}")
  scope      = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this[each.key].id : azurerm_private_endpoint.this_unmanaged_dns_zone_groups[each.key].id

  depends_on = [
    azurerm_linux_function_app.this,
    azurerm_windows_function_app.this,
    azurerm_private_endpoint.this,
    azurerm_role_assignment.this,
    azurerm_monitor_diagnostic_setting.this
  ]
}