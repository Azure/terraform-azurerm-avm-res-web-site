resource "azapi_resource_action" "this" {
  action      = "extensions/zipdeploy"
  method      = "PUT"
  resource_id = var.parent_id
  type        = local.type
  body = {
    packageUri = var.zip_deploy_file
  }

  lifecycle {
    ignore_changes = [body]
  }
}
