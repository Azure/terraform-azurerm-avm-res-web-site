resource "azapi_resource_action" "this" {
  action      = "extensions/onedeploy"
  method      = "PUT"
  resource_id = var.parent_id
  type        = local.type
  body = {
    properties = {
      packageUri = var.zip_deploy_file
      type       = "zip"
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
    ignore_changes = [body, response_export_values]

    precondition {
      condition     = length(var.ignore_body_changes.web_sites) == 0 && length(var.ignore_body_changes.web_sites_slots) == 0
      error_message = "`ignore_body_changes` is not supported here. This module manages its resource with `azapi_resource_action`, which the AzAPI provider does not give an `ignore_body_changes` argument, so any value set would be silently ignored."
    }
  }
}
