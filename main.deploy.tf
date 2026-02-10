resource "azapi_resource_action" "zip_deploy" {
  count = var.zip_deploy_file != null ? 1 : 0

  action      = "extensions/zipdeploy"
  method      = "PUT"
  resource_id = azapi_resource.this.id
  type        = "Microsoft.Web/sites@2025-03-01"
  body = {
    packageUri = var.zip_deploy_file
  }

  depends_on = [
    azapi_resource.appsettings,
    azapi_resource.connectionstrings,
  ]
}
