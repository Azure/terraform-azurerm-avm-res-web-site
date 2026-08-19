resource "azapi_resource" "this" {
  location            = var.location
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.web_sites
  body                = local.body
  create_headers      = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers      = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes = length(var.ignore_body_changes.web_sites) > 0 ? var.ignore_body_changes.web_sites : null
  delete_query_parameters = {
    deleteEmptyServerFarm = [tostring(var.delete_empty_service_plan)]
  }
  ignore_null_property = true
  read_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "properties.defaultHostName",
    "properties.customDomainVerificationId",
    "identity.principalId",
  ]
  retry          = var.retry
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = module.site_config_helpers.has_identity ? [module.site_config_helpers.identity_block] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
