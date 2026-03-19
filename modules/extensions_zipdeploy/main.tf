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

  lifecycle {
    ignore_changes = [body]
  }
}
