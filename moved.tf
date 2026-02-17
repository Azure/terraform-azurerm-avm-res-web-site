# Moved blocks for migrating from azurerm provider resources to azapi provider resources.
# These blocks enable in-place state migration when upgrading to this version of the module.
# Only the moved block whose source exists in state will be processed; the others are no-ops.

# ===========================
# Main App Resource
# ===========================

moved {
  from = azurerm_linux_web_app.this[0]
  to   = azapi_resource.this
}

# ===========================
# Deployment Slots
# ===========================

moved {
  from = module.slot.azapi_resource.this
  to   = azapi_resource.slot
}

# ===========================
# Application Insights
# ===========================

moved {
  from = azurerm_application_insights.this[0]
  to   = azapi_resource.application_insights["main"]
}

moved {
  from = azurerm_application_insights.slot
  to   = azapi_resource.application_insights
}

# ===========================
# Custom Hostname Bindings
# ===========================

moved {
  from = azurerm_app_service_custom_hostname_binding.this
  to   = module.hostname_binding.azapi_resource.this
}

moved {
  from = azurerm_app_service_slot_custom_hostname_binding.slot
  to   = module.slot_hostname_binding.azapi_resource.this
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

# Note: Slot locks are now managed inside module.slot. Terraform cannot automatically
# migrate these because the instance key structure differs (flat for_each → module for_each + count).
# If upgrading from the azurerm-based version, slot locks will be destroyed and recreated.

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

# Note: Slot role assignments are now managed inside module.slot. They will be
# destroyed and recreated when upgrading due to instance key structure changes.

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
  to   = azapi_resource.private_dns_zone_group
}

# Note: Slot private endpoints are now managed inside module.slot. They will be
# destroyed and recreated when upgrading due to instance key structure changes.

# ===========================
# Diagnostic Settings
# ===========================

moved {
  from = azurerm_monitor_diagnostic_setting.this
  to   = azapi_resource.diagnostic_setting
}
