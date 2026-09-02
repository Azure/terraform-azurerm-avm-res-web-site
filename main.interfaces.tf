module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.7.0"

  diagnostic_settings_v2 = var.diagnostic_settings
  enable_telemetry       = var.enable_telemetry
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
  for_each = module.avm_interfaces.lock_azapi != null ? { "lock" = module.avm_interfaces.lock_azapi } : {}

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = var.resource_types.authorization_locks
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = var.resource_types.authorization_role_assignments
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  ignore_null_property   = true
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azapi_resource" "private_endpoint" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  location               = coalesce(try(var.private_endpoints[each.key].location, null), var.location)
  name                   = each.value.name
  parent_id              = local.private_endpoint_parent_ids[each.key]
  type                   = var.resource_types.network_private_endpoints
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints) > 0 ? var.ignore_body_changes.network_private_endpoints : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  # Private endpoint tags are defined per endpoint by the AVM interface.
  # tflint-ignore: avm_azapi_resource_tags_required
  tags           = each.value.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azapi_resource" "private_dns_zone_group" {
  for_each = module.avm_interfaces.private_dns_zone_groups_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.key].id
  type                   = var.resource_types.network_private_endpoints_private_dns_zone_groups
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints_private_dns_zone_groups) > 0 ? var.ignore_body_changes.network_private_endpoints_private_dns_zone_groups : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azapi_resource" "lock_private_endpoint" {
  for_each = module.avm_interfaces.lock_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.value.private_endpoint_key].id
  type                   = var.resource_types.authorization_locks
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azapi_resource" "role_assignment_private_endpoint" {
  for_each = module.avm_interfaces.role_assignments_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoint[each.value.pe_key].id
  type                   = var.resource_types.authorization_role_assignments
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azapi_resource" "diagnostic_setting" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi_v2

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = var.resource_types.insights_diagnostic_settings
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.insights_diagnostic_settings) > 0 ? var.ignore_body_changes.insights_diagnostic_settings : null
  ignore_null_property   = true
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
