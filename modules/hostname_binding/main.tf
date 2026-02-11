locals {
  # Determine the ARM type based on whether the parent is a site or a slot
  is_slot = can(regex("/slots/", var.parent_id))
  type    = local.is_slot ? "Microsoft.Web/sites/slots/hostNameBindings@2025-03-01" : "Microsoft.Web/sites/hostNameBindings@2025-03-01"
}

resource "azapi_resource" "this" {
  name      = var.hostname
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = {
      sslState   = var.ssl_state
      thumbprint = var.thumbprint_value
    }
  }
  response_export_values = []
}
