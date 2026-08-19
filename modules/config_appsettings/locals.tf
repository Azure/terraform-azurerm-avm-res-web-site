locals {
  type = var.is_slot ? var.resource_types.web_sites_slots_config : var.resource_types.web_sites_config
}
