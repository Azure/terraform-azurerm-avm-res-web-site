locals {
  # Determine the ARM type based on whether the parent is a site or a slot
  ignore_body_changes = local.is_slot ? var.ignore_body_changes.web_sites_slots_host_name_bindings : var.ignore_body_changes.web_sites_host_name_bindings
  is_slot             = can(regex("/slots/", var.parent_id))
  type                = local.is_slot ? var.resource_types.web_sites_slots_host_name_bindings : var.resource_types.web_sites_host_name_bindings
}
