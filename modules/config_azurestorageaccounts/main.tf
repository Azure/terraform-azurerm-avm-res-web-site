resource "azapi_resource" "this" {
  name      = "azurestorageaccounts"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = local.storage_mounts
  }
  response_export_values = []
}
