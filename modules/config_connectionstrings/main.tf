resource "azapi_update_resource" "this" {
  name      = "connectionstrings"
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = { for k, v in var.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    } }
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
