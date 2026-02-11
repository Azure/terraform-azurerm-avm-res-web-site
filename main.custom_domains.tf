module "hostname_binding" {
  source   = "./modules/hostname_binding"
  for_each = { for k, v in var.custom_domains : k => v if !v.slot_as_target }

  hostname         = each.value.hostname
  parent_id        = azapi_resource.this.id
  ssl_state        = each.value.ssl_state
  thumbprint_value = each.value.thumbprint_value
}

module "slot_hostname_binding" {
  source   = "./modules/hostname_binding"
  for_each = { for k, v in var.custom_domains : k => v if v.slot_as_target }

  hostname         = each.value.hostname
  parent_id        = module.slot[each.value.app_service_slot_key].resource_id
  ssl_state        = each.value.ssl_state
  thumbprint_value = each.value.thumbprint_value
}
