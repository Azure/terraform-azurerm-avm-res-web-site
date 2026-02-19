locals {
  type = var.is_slot ? "Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2025-03-01" : "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-03-01"
}
