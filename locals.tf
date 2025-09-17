locals {
  # Custom domain verification id
  custom_domain_verification_id = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.function_app_uses_fc1 == true ? azurerm_function_app_flex_consumption.this[0].custom_domain_verification_id : (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].custom_domain_verification_id : azurerm_linux_function_app.this[0].custom_domain_verification_id)) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].custom_domain_verification_id : azurerm_linux_web_app.this[0].custom_domain_verification_id)) : null
  # Checks if there are deployment slots, and grabs keys of slots
  deployment_slot_keys = length(var.deployment_slots) > 0 ? keys(var.deployment_slots) : null
  # Function app slot references for hybrid connections
  function_app_slot_ids = var.kind == "functionapp" ? (
    var.os_type == "Windows" ? {
      for key, slot in azurerm_windows_function_app_slot.this : key => slot.id
      } : {
      for key, slot in azurerm_linux_function_app_slot.this : key => slot.id
    }
  ) : {}
  # Web app slot references for hybrid connections
  web_app_slot_ids = var.kind == "webapp" ? (
    var.os_type == "Windows" ? {
      for key, slot in azurerm_windows_web_app_slot.this : key => slot.id
      } : {
      for key, slot in azurerm_linux_web_app_slot.this : key => slot.id
    }
  ) : {}
  function_app_slot_send_key_values = var.kind == "functionapp" ? {
    for key, value in var.function_app_slot_hybrid_connections :
    key => value.send_key_name == "RootManageSharedAccessKey" ?
    data.azapi_resource_action.function_app_slot_relay_namespace_keys[key].output.primaryKey :
    coalesce(
      try(data.azapi_resource_action.function_app_slot_relay_namespace_keys[key].output.primaryKey, null),
      try(data.azapi_resource_action.function_app_slot_relay_hybrid_connection_keys[key].output.primaryKey, null)
    )
  } : {}
  # Managed identities
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
  # Private endpoints
  pe_role_assignments = { for ra in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for rk, rv in pe_v.role_assignments : {
        private_endpoint_key = pe_k
        ra_key               = rk
        role_assignment      = rv
      }
    ]
  ]) : "${ra.private_endpoint_key}-${ra.ra_key}" => ra }
  # Private endpoint application security group associations
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  # Deployment slot private endpoints
  slot_pe = { for pe in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for pe_k, pe_v in slot_v.private_endpoints : {
        slot_key = slot_k
        pe_key   = pe_k
        pe_value = pe_v
      }
    ]
  ]) : "${pe.slot_key}-${pe.pe_key}" => pe }
  slot_pe_role_assignments = { for ra in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for pe_k, pe_v in slot_v.private_endpoints : [
        for rk, rv in pe_v.role_assignments : {
          private_endpoint_key = pe_k
          ra_key               = rk
          role_assignment      = rv
        }
      ]
    ]
  ]) : "${ra.private_endpoint_key}-${ra.ra_key}" => ra }
  slot_private_endpoint_application_security_group_associations = { for assoc in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for pe_k, pe_v in slot_v.private_endpoints : [
        for asg_k, asg_v in pe_v.application_security_group_associations : {
          asg_key         = asg_k
          pe_key          = pe_k
          asg_resource_id = asg_v
        }
      ]
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  # Deployment slot role assignments
  slot_ra = { for ra in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for rk, rv in slot_v.role_assignments : {
        slot_key        = slot_k
        ra_key          = rk
        role_assignment = rv
      }
    ]
  ]) : "${ra.slot_key}-${ra.ra_key}" => ra }
  web_app_slot_send_key_values = var.kind == "webapp" ? {
    for key, value in var.web_app_slot_hybrid_connections :
    key => value.send_key_name == "RootManageSharedAccessKey" ?
    data.azapi_resource_action.web_app_slot_relay_namespace_keys[key].output.primaryKey :
    coalesce(
      try(data.azapi_resource_action.web_app_slot_relay_namespace_keys[key].output.primaryKey, null),
      try(data.azapi_resource_action.web_app_slot_relay_hybrid_connection_keys[key].output.primaryKey, null)
    )
  } : {}
  webapp_alk                  = local.webapp_logs_key != null ? local.webapp_application_logs_key[0] : null             # Grabs the key for the `application_logs` object
  webapp_application_logs_key = local.webapp_logs_key != null ? keys(var.logs[local.webapp_lk].application_logs) : null # Helps with identifying local `webapp_alk`
  # Stores useful key information about the `logs` object for the main webapp
  webapp_keys = {
    logs_key             = local.webapp_logs_key
    application_logs_key = local.webapp_application_logs_key
    lk                   = local.webapp_lk
    alk                  = local.webapp_alk
  }
  webapp_lk = local.webapp_logs_key != null ? local.webapp_logs_key[0] : null
  # Grabs the key for the `logs` object
  webapp_logs_key = length(var.logs) == 1 ? keys(var.logs) : null
  # Creates a map of webapp slots that have logs, identifies key(s) and stores some infomation about the configuration
  webapp_slot_lk = local.webapp_slots_with_logs_keys != null ? { for x in local.webapp_slots_with_logs_keys : x =>
    {
      keys = keys(var.deployment_slots[x].logs)
      # For testing purposes
      log_settings = var.deployment_slots[x].logs[keys(var.deployment_slots[x].logs)[0]]
      # Identifies the key for the `file_system_level`
      file_system_level_key = keys(var.deployment_slots[x].logs[keys(var.deployment_slots[x].logs)[0]].application_logs)[0]
    }
  } : null
  # Checks is there are deployment slots, and grabs keys of slots that have logs
  webapp_slots_with_logs_keys = local.deployment_slot_keys != null ? [for x in local.deployment_slot_keys : x if length(var.deployment_slots[x].logs) == 1] : null
}
