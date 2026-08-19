resource "azapi_update_resource" "this" {
  name      = "appsettings"
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = var.app_settings
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
