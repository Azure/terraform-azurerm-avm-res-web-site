resource "azapi_update_resource" "this" {
  name      = "slotConfigNames"
  parent_id = var.parent_id
  type      = var.resource_types.web_sites_config
  body = {
    properties = {
      appSettingNames       = var.app_setting_names
      connectionStringNames = var.connection_string_names
    }
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
