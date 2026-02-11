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

/* moved {
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
} */

# ===========================
# Deployment Slots
# ===========================
# Four mutually exclusive slot types consolidated into the slot submodule.
# Chained: azurerm_*_slot.this → azapi_resource.slot → module.slot.azapi_resource.this

moved {
  from = azurerm_linux_web_app_slot.this
  to   = azapi_resource.slot
}

/* moved {
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
} */

moved {
  from = azapi_resource.slot
  to   = module.slot.azapi_resource.this
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
# Chained: azurerm_*_hostname_binding → azapi_resource.hostname_binding → module.hostname_binding.azapi_resource.this

moved {
  from = azurerm_app_service_custom_hostname_binding.this
  to   = azapi_resource.hostname_binding
}

moved {
  from = azurerm_app_service_slot_custom_hostname_binding.slot
  to   = azapi_resource.slot_hostname_binding
}

moved {
  from = azapi_resource.hostname_binding
  to   = module.hostname_binding.azapi_resource.this
}

moved {
  from = azapi_resource.slot_hostname_binding
  to   = module.slot_hostname_binding.azapi_resource.this
}

# ===========================
# Config Resources → Submodules
# ===========================
# Resources that used count are mapped to module for_each with explicit instance keys.
# Resources that used for_each are mapped with matching keys.

moved {
  from = azapi_resource.appsettings[0]
  to   = module.config_appsettings["default"].azapi_resource.this
}

moved {
  from = azapi_resource.connectionstrings[0]
  to   = module.config_connectionstrings["default"].azapi_resource.this
}

moved {
  from = azapi_resource.azurestorageaccounts[0]
  to   = module.config_azurestorageaccounts["default"].azapi_resource.this
}

moved {
  from = azapi_resource.slotconfignames[0]
  to   = module.config_slotconfignames["default"].azapi_resource.this
}

moved {
  from = azapi_resource.backup
  to   = module.config_backup.azapi_resource.this
}

moved {
  from = azapi_resource.logs
  to   = module.config_logs.azapi_resource.this
}

moved {
  from = azapi_resource.authsettings
  to   = module.config_authsettings.azapi_resource.this
}

moved {
  from = azapi_resource.authsettingsv2
  to   = module.config_authsettingsv2.azapi_resource.this
}

moved {
  from = azapi_resource.ftp_publishing_credential_policy[0]
  to   = module.ftp_publishing_credential_policy["default"].azapi_resource.this
}

moved {
  from = azapi_resource.scm_publishing_credential_policy[0]
  to   = module.scm_publishing_credential_policy["default"].azapi_resource.this
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
