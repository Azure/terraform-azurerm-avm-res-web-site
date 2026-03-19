resource "azapi_update_resource" "this" {
  name      = "connectionstrings"
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = { for k, v in var.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    } }
  }
  response_export_values = []
  retry                  = var.retry
}
