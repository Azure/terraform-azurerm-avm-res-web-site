locals {
  # Determine the ARM type based on whether the parent is a site or a slot
  is_slot = can(regex("/slots/", var.parent_id))
  type    = local.is_slot ? "Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2025-03-01" : "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-03-01"
}

resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.parent_id
  type      = local.type
  body = {
    properties = {
      allow = var.allow
    }
  }
  response_export_values = []
}
