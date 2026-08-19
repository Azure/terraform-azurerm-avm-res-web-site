locals {
  type = var.is_slot ? var.resource_types.web_sites_slots_basic_publishing_credentials_policies : var.resource_types.web_sites_basic_publishing_credentials_policies
}
