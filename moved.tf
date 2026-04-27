# Moved blocks for migrating from azurerm provider resources to azapi provider resources.
# These blocks enable in-place state migration when upgrading to this version of the module.
# Only the moved block whose source exists in state will be processed; the others are no-ops.

# ===========================
# Main App Resource
# ===========================
#
# NOTE: A `moved` block for the main site resource is intentionally NOT provided
# here. Earlier versions of this module used different `azurerm_*` resource types
# depending on the configured app kind (for example
# `azurerm_linux_web_app`, `azurerm_windows_web_app`, `azurerm_linux_function_app`,
# `azurerm_windows_function_app`, `azurerm_function_app_flex_consumption`,
# `azurerm_logic_app_standard`). Shipping a single `moved` block in this module
# would either silently change the app's `kind` (for example forcing a Function
# App or Logic App to be treated as a Web App) or produce an "Ambiguous move
# statements" error when combined with a user-supplied `moved` block.
#
# Consumers upgrading from an earlier release of this module should add a
# `moved` block in their own root configuration that matches the resource type
# they previously had in state. See the "Migration from earlier module
# versions" section of the module README for ready-to-copy examples for each
# app flavour (Linux/Windows Web App, Linux/Windows Function App, Flex
# Consumption Function App, and Logic App Standard).

# ===========================
# Custom Hostname Bindings
# ===========================

moved {
  from = azurerm_app_service_custom_hostname_binding.this
  to   = module.hostname_binding.azapi_resource.this
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
