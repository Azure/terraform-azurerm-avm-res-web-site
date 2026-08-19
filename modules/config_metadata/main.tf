resource "azapi_resource_action" "this" {
  method      = "PUT"
  resource_id = "${var.parent_id}/config/metadata"
  type        = local.type
  body = {
    properties = var.metadata
  }
  retry = var.retry

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
