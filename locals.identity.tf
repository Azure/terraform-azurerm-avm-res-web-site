locals {
  has_identity = local.managed_identity_type != null
  identity_block = local.has_identity ? {
    type         = local.managed_identity_type
    identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? tolist(var.managed_identities.user_assigned_resource_ids) : null
  } : null
  managed_identity_type = (
    var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.managed_identities.system_assigned ? "SystemAssigned" :
    length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" :
    null
  )
}
