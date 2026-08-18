resource "azapi_resource" "this" {
  name      = var.hostname
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = {
      sslState   = var.ssl_state
      thumbprint = var.thumbprint
    }
  }
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
}
