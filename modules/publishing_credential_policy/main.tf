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
}
