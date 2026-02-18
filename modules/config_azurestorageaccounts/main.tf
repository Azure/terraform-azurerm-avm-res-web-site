resource "azapi_resource_action" "this" {
  action      = "config/azurestorageaccounts"
  method      = "PUT"
  resource_id = var.parent_id
  type        = local.type
  body = {
    properties = local.storage_mounts
  }
}
