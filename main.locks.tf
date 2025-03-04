resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.function_app_uses_fc1 == true ? azurerm_function_app_flex_consumption.this[0].id : (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id)) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id)) : null
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the app service or its child resources." : "Cannot delete or modify the app service or its child resources."

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

# Module to no longer support the creation/management of Storage Accounts

# resource "azurerm_management_lock" "storage_account" {
#   count = (var.lock != null && (var.all_child_resources_inherit_lock || var.function_app_storage_account_inherit_lock)) || var.function_app_storage_account.lock != null ? 1 : 0

#   lock_level = ((var.all_child_resources_inherit_lock || var.function_app_storage_account_inherit_lock) && var.lock != null) ? var.lock.kind : var.function_app_storage_account.lock.kind
#   name       = coalesce(var.function_app_storage_account.lock.name, "lock-${var.name}")
#   scope      = var.
#   notes      = var.function_app_storage_account.lock.kind == "CanNotDelete" ? "Cannot delete the storage account or its child resources." : "Cannot delete or modify the storage account or its child resources."

#   depends_on = [
#     azurerm_linux_function_app.this,
#     azurerm_windows_function_app.this,
#     azurerm_private_endpoint.this,
#     azurerm_role_assignment.this,
#     azurerm_monitor_diagnostic_setting.this
#   ]
# }

resource "azurerm_management_lock" "slot" {
  for_each = { for slot, slot_values in var.deployment_slots : slot => slot_values if(((var.all_child_resources_inherit_lock || var.deployment_slots_inherit_lock) && var.lock != null) || (slot_values.lock != null)) }

  lock_level = ((var.all_child_resources_inherit_lock || var.deployment_slots_inherit_lock) && var.lock != null) ? var.lock.kind : each.value.lock.kind
  name       = "lock-${coalesce(each.value.name, "slot-${var.name}")}"
  scope      = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? azurerm_windows_function_app_slot.this[each.key].id : azurerm_linux_function_app_slot.this[each.key].id) : (var.os_type == "Windows" ? azurerm_windows_web_app_slot.this[each.key].id : azurerm_linux_web_app_slot.this[each.key].id)) : null
  notes      = each.value.lock.kind == "CanNotDelete" ? "Cannot delete the deployment slot or its child resources." : "Cannot delete or modify the deployment slot or its child resources."

  depends_on = [
    azurerm_linux_function_app.this,
    azurerm_windows_function_app.this,
    azurerm_private_endpoint.this,
    azurerm_role_assignment.this,
    azurerm_monitor_diagnostic_setting.this
  ]
}