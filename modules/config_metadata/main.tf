resource "azapi_resource_action" "this" {
  method      = "PUT"
  resource_id = "${var.parent_id}/config/metadata"
  type        = local.type
  body = {
    properties = var.metadata
  }
  response_export_values = []
  retry                  = var.retry

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
    precondition {
      condition     = length(var.ignore_body_changes.web_sites_config) == 0 && length(var.ignore_body_changes.web_sites_slots_config) == 0
      error_message = "`ignore_body_changes` is not supported here. This module manages its resource with `azapi_resource_action`, which the AzAPI provider does not give an `ignore_body_changes` argument, so any value set would be silently ignored."
    }
  }
}
