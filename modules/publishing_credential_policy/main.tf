resource "azapi_update_resource" "this" {
  name      = var.name
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = {
      allow = var.allow
    }
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
      condition     = length(var.ignore_body_changes.web_sites_basic_publishing_credentials_policies) == 0 && length(var.ignore_body_changes.web_sites_slots_basic_publishing_credentials_policies) == 0
      error_message = "`ignore_body_changes` is not supported here. This module manages its resource with `azapi_update_resource`, which the AzAPI provider does not give an `ignore_body_changes` argument, so any value set would be silently ignored."
    }
  }
}
