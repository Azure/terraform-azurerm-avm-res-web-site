resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.web_sites
  body      = local.body
  delete_query_parameters = {
    deleteEmptyServerFarm = [tostring(var.delete_empty_service_plan)]
  }
  ignore_body_changes  = length(var.ignore_body_changes.web_sites) > 0 ? var.ignore_body_changes.web_sites : null
  ignore_null_property = true
  response_export_values = [
    "properties.defaultHostName",
    "properties.customDomainVerificationId",
    "identity.principalId",
  ]
  retry = var.retry
  tags  = var.tags

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
}
