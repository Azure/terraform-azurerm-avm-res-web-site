module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.5.1"

  lock               = var.lock
  managed_identities = var.managed_identities
  private_endpoints = {
    for k, v in var.private_endpoints : k => merge(v, {
      subresource_name = "sites-${var.name}"
      lock             = v.lock != null ? v.lock : (var.private_endpoints_inherit_lock && var.lock != null ? var.lock : null)
      ip_configurations = {
        for ip_key, ip_val in v.ip_configurations : ip_key => merge(ip_val, {
          member_name = coalesce(ip_val.member_name, "sites-${var.name}")
        })
      }
    })
  }
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  private_endpoints_scope                 = var.parent_id
  role_assignment_definition_scope        = azapi_resource.this.id
  role_assignments                        = var.role_assignments
}

resource "azapi_resource" "lock" {
  for_each = module.avm_interfaces.lock_azapi != null ? { "lock" = module.avm_interfaces.lock_azapi } : {}

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  response_export_values = []
}

resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  ignore_null_property   = true
  response_export_values = []
}

resource "azapi_resource" "private_endpoint" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  location               = coalesce(try(var.private_endpoints[each.key].location, null), var.location)
  name                   = each.value.name
  parent_id              = regex("^(/subscriptions/[^/]+/resourceGroups/[^/]+)", var.parent_id)[0]
  type                   = each.value.type
  body                   = each.value.body
  response_export_values = []
  tags                   = each.value.tags
}

resource "azapi_resource" "private_dns_zone_group" {
  for_each = module.avm_interfaces.private_dns_zone_groups_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.key].id
  type                   = each.value.type
  body                   = each.value.body
  response_export_values = []
}

resource "azapi_resource" "lock_private_endpoint" {
  for_each = module.avm_interfaces.lock_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.value.private_endpoint_key].id
  type                   = each.value.type
  body                   = each.value.body
  response_export_values = []
}

resource "azapi_resource" "role_assignment_private_endpoint" {
  for_each = module.avm_interfaces.role_assignments_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.value.private_endpoint_key].id
  type                   = each.value.type
  body                   = each.value.body
  response_export_values = []
}
