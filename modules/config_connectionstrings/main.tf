resource "azapi_resource" "this" {
  name      = "connectionstrings"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = { for k, v in var.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    } }
  }
  response_export_values = []
}
