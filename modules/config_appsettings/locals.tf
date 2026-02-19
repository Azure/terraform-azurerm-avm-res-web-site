locals {
  type = var.is_slot ? "Microsoft.Web/sites/slots/config@2025-03-01" : "Microsoft.Web/sites/config@2025-03-01"
}
