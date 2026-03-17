resource "azapi_resource_action" "this" {
  method      = "PUT"
  resource_id = "${var.parent_id}/config/metadata"
  type        = local.type
  body = {
    properties = var.metadata
  }
}
