resource "azapi_update_resource" "this" {
  name      = "appsettings"
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = var.app_settings
  }
  response_export_values = []
}
