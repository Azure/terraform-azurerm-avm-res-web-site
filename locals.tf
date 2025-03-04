locals {
  # Custom domain verification id
  custom_domain_verification_id = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.function_app_uses_fc1 == true ? azurerm_function_app_flex_consumption.this[0].custom_domain_verification_id : (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].custom_domain_verification_id : azurerm_linux_function_app.this[0].custom_domain_verification_id)) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].custom_domain_verification_id : azurerm_linux_web_app.this[0].custom_domain_verification_id)) : null
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
}
