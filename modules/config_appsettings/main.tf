resource "azapi_resource" "this" {
  name      = "appsettings"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = var.app_settings
  }
  response_export_values = []
}
