locals {
  type = var.is_slot ? var.resource_types.web_sites_slots : var.resource_types.web_sites
}
