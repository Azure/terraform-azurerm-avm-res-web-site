resource "azapi_update_resource" "this" {
  name      = var.name
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = {
      allow = var.allow
    }
  }
  response_export_values = []
  retry                  = var.retry
}
