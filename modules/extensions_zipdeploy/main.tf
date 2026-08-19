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

  lifecycle {
    ignore_changes = [body]
  }
}
