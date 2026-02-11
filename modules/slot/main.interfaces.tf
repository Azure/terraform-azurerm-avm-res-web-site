# Slot lock
resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.name}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete resource or child resources." : "Cannot delete or modify the resource or child resources."
    }
  }
  response_export_values = []
}

# Slot role assignments
resource "azapi_resource" "role_assignment" {
  for_each = local.role_assignments_flat

  name      = each.key
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId                        = each.value.principal_id
      roleDefinitionId                   = strcontains(each.value.role_definition_id_or_name, local.role_definition_resource_substring) ? each.value.role_definition_id_or_name : "${azapi_resource.this.id}${local.role_definition_resource_substring}/${each.value.role_definition_id_or_name}"
      description                        = each.value.description
      principalType                      = each.value.principal_type
      condition                          = each.value.condition
      conditionVersion                   = each.value.condition_version
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
    }
  }
  response_export_values = []
}

# Slot private endpoints
resource "azapi_resource" "private_endpoint" {
  for_each = var.private_endpoints

  location  = coalesce(each.value.location, var.location)
  name      = coalesce(each.value.name, "pe-${each.key}")
  parent_id = each.value.resource_group_name != null ? "/subscriptions/${local.subscription_id}/resourceGroups/${each.value.resource_group_name}" : local.resource_group_id
  type      = "Microsoft.Network/privateEndpoints@2025-03-01"
  body = {
    properties = {
      subnet = {
        id = each.value.subnet_resource_id
      }
      privateLinkServiceConnections = [{
        name = coalesce(each.value.private_service_connection_name, "psc-${each.key}")
        properties = {
          privateLinkServiceId = azapi_resource.this.id
          groupIds             = ["sites-${var.name}"]
        }
      }]
      customNetworkInterfaceName = each.value.network_interface_name
      ipConfigurations = length(each.value.ip_configurations) > 0 ? [
        for ip_k, ip_v in each.value.ip_configurations : {
          name = ip_v.name
          properties = {
            privateIPAddress = ip_v.private_ip_address
            groupId          = "sites-${var.name}"
            memberName       = "sites-${var.name}"
          }
        }
      ] : null
    }
  }
  response_export_values = []
  tags                   = each.value.tags
}

# Slot private DNS zone groups
resource "azapi_resource" "private_dns_zone_group" {
  for_each = {
    for k, v in var.private_endpoints : k => v
    if var.private_endpoints_manage_dns_zone_group && length(v.private_dns_zone_resource_ids) > 0
  }

  name      = each.value.private_dns_zone_group_name
  parent_id = azapi_resource.private_endpoint[each.key].id
  type      = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-03-01"
  body = {
    properties = {
      privateDnsZoneConfigs = [for idx, zone_id in tolist(each.value.private_dns_zone_resource_ids) : {
        name = "dnszone${idx}"
        properties = {
          privateDnsZoneId = zone_id
        }
      }]
    }
  }
  response_export_values = []
}

# Slot private endpoint locks
resource "azapi_resource" "pe_lock" {
  for_each = {
    for k, v in var.private_endpoints : k => v
    if v.lock != null || (var.private_endpoints_inherit_lock && var.lock != null)
  }

  name      = "lock-${each.key}"
  parent_id = azapi_resource.private_endpoint[each.key].id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = coalesce(try(each.value.lock.kind, null), try(var.lock.kind, null))
    }
  }
  response_export_values = []
}

# Slot private endpoint role assignments
resource "azapi_resource" "pe_role_assignment" {
  for_each = local.pe_role_assignments

  name      = each.value.ra_key
  parent_id = azapi_resource.private_endpoint[each.value.private_endpoint_key].id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = each.value.role_assignment.principal_id
      roleDefinitionId = strcontains(each.value.role_assignment.role_definition_id_or_name, local.role_definition_resource_substring) ? each.value.role_assignment.role_definition_id_or_name : "${azapi_resource.private_endpoint[each.value.private_endpoint_key].id}${local.role_definition_resource_substring}/${each.value.role_assignment.role_definition_id_or_name}"
      description      = each.value.role_assignment.description
      principalType    = each.value.role_assignment.principal_type
      condition        = each.value.role_assignment.condition
      conditionVersion = each.value.role_assignment.condition_version
    }
  }
  response_export_values = []
}
