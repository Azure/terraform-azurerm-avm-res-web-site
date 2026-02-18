resource "azapi_update_resource" "this" {
  name      = "azurestorageaccounts"
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = local.storage_mounts
  }
  response_export_values = []
}
