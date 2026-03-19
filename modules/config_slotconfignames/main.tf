resource "azapi_update_resource" "this" {
  name      = "slotConfigNames"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      appSettingNames       = var.app_setting_names
      connectionStringNames = var.connection_string_names
    }
  }
  response_export_values = []
  retry                  = var.retry
}
