resource "azapi_resource" "this" {
  name      = var.hostname
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = {
      sslState   = var.ssl_state
      thumbprint = var.thumbprint
    }
  }
  ignore_body_changes    = length(local.ignore_body_changes) > 0 ? local.ignore_body_changes : null
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
