resource "azapi_resource_action" "this" {
  action      = "config/azurestorageaccounts"
  method      = "PUT"
  resource_id = var.parent_id
  type        = local.type
  body = {
    properties = local.storage_mounts
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
