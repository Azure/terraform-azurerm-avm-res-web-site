locals {
  type = var.is_slot ? "Microsoft.Web/sites/slots@2025-03-01" : "Microsoft.Web/sites@2025-03-01"
}
