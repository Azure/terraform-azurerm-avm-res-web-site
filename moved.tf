# Moved blocks for migrating from azurerm provider resources to azapi provider resources.
# These blocks enable in-place state migration when upgrading to this version of the module.
# Only the moved block whose source exists in state will be processed; the others are no-ops.

# ===========================
# Main App Resource
# ===========================
# The six mutually exclusive azurerm app resources are consolidated into a single
# azapi_resource.this. Only one of these will match a given deployment's state.

moved {
  from = azurerm_linux_web_app.this[0]
  to   = azapi_resource.this
}

moved {
  from = azurerm_windows_web_app.this[0]
  to   = azapi_resource.this
}

moved {
  from = azurerm_linux_function_app.this[0]
  to   = azapi_resource.this
}

moved {
  from = azurerm_windows_function_app.this[0]
  to   = azapi_resource.this
}

moved {
  from = azurerm_function_app_flex_consumption.this[0]
  to   = azapi_resource.this
}

moved {
  from = azurerm_logic_app_standard.this[0]
  to   = azapi_resource.this
}

# ===========================
# Deployment Slots
# ===========================
# Four mutually exclusive slot types consolidated into azapi_resource.slot.
# Keys from var.deployment_slots are preserved.

moved {
  from = azurerm_linux_web_app_slot.this
  to   = azapi_resource.slot
}

moved {
  from = azurerm_windows_web_app_slot.this
  to   = azapi_resource.slot
}

moved {
  from = azurerm_linux_function_app_slot.this
  to   = azapi_resource.slot
}

moved {
  from = azurerm_windows_function_app_slot.this
  to   = azapi_resource.slot
}

# ===========================
# Application Insights
# ===========================

moved {
  from = azurerm_application_insights.this[0]
  to   = azapi_resource.application_insights[0]
}

moved {
  from = azurerm_application_insights.slot
  to   = azapi_resource.slot_application_insights
}

# ===========================
# Custom Hostname Bindings
# ===========================

moved {
  from = azurerm_app_service_custom_hostname_binding.this
  to   = azapi_resource.hostname_binding
}

moved {
  from = azurerm_app_service_slot_custom_hostname_binding.slot
  to   = azapi_resource.slot_hostname_binding
}

# ===========================
# Locks
# ===========================

moved {
  from = azurerm_management_lock.this[0]
  to   = azapi_resource.lock["lock"]
}

moved {
  from = azurerm_management_lock.pe
  to   = azapi_resource.lock_private_endpoint
}

moved {
  from = azurerm_management_lock.slot
  to   = azapi_resource.slot_lock
}

# ===========================
# Role Assignments
# ===========================

moved {
  from = azurerm_role_assignment.this
  to   = azapi_resource.role_assignment
}

moved {
  from = azurerm_role_assignment.pe
  to   = azapi_resource.role_assignment_private_endpoint
}

moved {
  from = azurerm_role_assignment.slot
  to   = azapi_resource.slot_role_assignment
}

moved {
  from = azurerm_role_assignment.slot_pe
  to   = azapi_resource.slot_pe_role_assignment
}

# ===========================
# Private Endpoints
# ===========================
# The old module had two mutually exclusive PE resources based on
# var.private_endpoints_manage_dns_zone_group (true → managed, false → unmanaged).
# Both variants are now unified into a single azapi_resource.private_endpoint.

moved {
  from = azurerm_private_endpoint.this
  to   = azapi_resource.private_endpoint
}

moved {
  from = azurerm_private_endpoint.this_unmanaged_dns_zone_groups
  to   = azapi_resource.private_endpoint
}

moved {
  from = azurerm_private_endpoint.slot
  to   = azapi_resource.slot_private_endpoint
}

moved {
  from = azurerm_private_endpoint.slot_this_unmanaged_dns_zone_groups
  to   = azapi_resource.slot_private_endpoint
}

# ===========================
# Diagnostic Settings
# ===========================

moved {
  from = azurerm_monitor_diagnostic_setting.this
  to   = azapi_resource.diagnostic_setting
}
