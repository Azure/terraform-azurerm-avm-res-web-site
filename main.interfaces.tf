module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.5.0"

  diagnostic_settings_v2 = var.diagnostic_settings
  lock                   = var.lock
  managed_identities     = var.managed_identities
  private_endpoints = {
    for k, v in var.private_endpoints : k => merge(v, {
      subresource_name = "sites"
    })
  }
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  private_endpoints_scope                 = azapi_resource.this.id
  role_assignment_definition_scope        = azapi_resource.this.id
  role_assignments                        = var.role_assignments
}

resource "azapi_resource" "lock" {
  for_each = module.avm_interfaces.lock_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "private_endpoint" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  location               = each.value.location
  name                   = each.value.name
  parent_id              = each.value.parent_id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  tags                   = each.value.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "private_dns_zone_group" {
  for_each = module.avm_interfaces.private_dns_zone_groups_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.value.private_endpoint_key].id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "lock_private_endpoint" {
  for_each = module.avm_interfaces.lock_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.value.private_endpoint_key].id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "role_assignment_private_endpoint" {
  for_each = module.avm_interfaces.role_assignments_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.value.private_endpoint_key].id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "diagnostic_setting" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi_v2

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_null_property   = true
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slot_lock" {
  for_each = {
    for slot_key, slot_value in var.deployment_slots : slot_key => slot_value.lock != null ? slot_value.lock : (
      var.deployment_slots_inherit_lock && var.lock != null ? var.lock : null
    ) if(slot_value.lock != null || (var.deployment_slots_inherit_lock && var.lock != null))
  }

  name      = coalesce(each.value.name, "lock-${each.key}")
  parent_id = azapi_resource.slot[each.key].id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = each.value.kind
      notes = each.value.kind == "CanNotDelete" ? "Cannot delete resource or child resources." : "Cannot delete or modify the resource or child resources."
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slot_role_assignment" {
  for_each = local.slot_ra

  name      = each.value.ra_key
  parent_id = azapi_resource.slot[each.value.slot_key].id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId                        = each.value.role_assignment.principal_id
      roleDefinitionId                   = strcontains(each.value.role_assignment.role_definition_id_or_name, local.role_definition_resource_substring) ? each.value.role_assignment.role_definition_id_or_name : "${azapi_resource.slot[each.value.slot_key].id}${local.role_definition_resource_substring}/${each.value.role_assignment.role_definition_id_or_name}"
      description                        = each.value.role_assignment.description
      principalType                      = each.value.role_assignment.principal_type
      condition                          = each.value.role_assignment.condition
      conditionVersion                   = each.value.role_assignment.condition_version
      delegatedManagedIdentityResourceId = each.value.role_assignment.delegated_managed_identity_resource_id
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slot_private_endpoint" {
  for_each = local.slot_pe

  location  = coalesce(each.value.pe_value.location, var.location)
  name      = coalesce(each.value.pe_value.name, "pe-${each.key}")
  parent_id = each.value.pe_value.resource_group_name != null ? "/subscriptions/${local.subscription_id}/resourceGroups/${each.value.pe_value.resource_group_name}" : var.parent_id
  type      = "Microsoft.Network/privateEndpoints@2025-03-01"
  body = {
    properties = {
      subnet = {
        id = each.value.pe_value.subnet_resource_id
      }
      privateLinkServiceConnections = [{
        name = coalesce(each.value.pe_value.private_service_connection_name, "psc-${each.key}")
        properties = {
          privateLinkServiceId = azapi_resource.slot[each.value.slot_key].id
          groupIds             = ["sites-${coalesce(var.deployment_slots[each.value.slot_key].name, each.value.slot_key)}"]
        }
      }]
      customNetworkInterfaceName = each.value.pe_value.network_interface_name
      ipConfigurations = length(each.value.pe_value.ip_configurations) > 0 ? [
        for ip_k, ip_v in each.value.pe_value.ip_configurations : {
          name = ip_v.name
          properties = {
            privateIPAddress = ip_v.private_ip_address
            groupId          = "sites-${coalesce(var.deployment_slots[each.value.slot_key].name, each.value.slot_key)}"
            memberName       = "sites-${coalesce(var.deployment_slots[each.value.slot_key].name, each.value.slot_key)}"
          }
        }
      ] : null
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  tags                   = each.value.pe_value.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slot_private_dns_zone_group" {
  for_each = {
    for k, v in local.slot_pe : k => v
    if var.private_endpoints_manage_dns_zone_group && length(v.pe_value.private_dns_zone_resource_ids) > 0
  }

  name      = each.value.pe_value.private_dns_zone_group_name
  parent_id = azapi_resource.slot_private_endpoint[each.key].id
  type      = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-03-01"
  body = {
    properties = {
      privateDnsZoneConfigs = [for idx, zone_id in tolist(each.value.pe_value.private_dns_zone_resource_ids) : {
        name = "dnszone${idx}"
        properties = {
          privateDnsZoneId = zone_id
        }
      }]
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slot_pe_lock" {
  for_each = {
    for k, v in local.slot_pe : k => v
    if v.pe_value.lock != null || (var.private_endpoints_inherit_lock && var.lock != null)
  }

  name      = "lock-${each.key}"
  parent_id = azapi_resource.slot_private_endpoint[each.key].id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = coalesce(try(each.value.pe_value.lock.kind, null), try(var.lock.kind, null))
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slot_pe_role_assignment" {
  for_each = local.slot_pe_role_assignments

  name      = each.value.ra_key
  parent_id = azapi_resource.slot_private_endpoint[each.value.private_endpoint_key].id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = each.value.role_assignment.principal_id
      roleDefinitionId = strcontains(each.value.role_assignment.role_definition_id_or_name, local.role_definition_resource_substring) ? each.value.role_assignment.role_definition_id_or_name : "${azapi_resource.slot_private_endpoint[each.value.private_endpoint_key].id}${local.role_definition_resource_substring}/${each.value.role_assignment.role_definition_id_or_name}"
      description      = each.value.role_assignment.description
      principalType    = each.value.role_assignment.principal_type
      condition        = each.value.role_assignment.condition
      conditionVersion = each.value.role_assignment.condition_version
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
