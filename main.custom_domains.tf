module "hostname_binding" {
  source   = "./modules/hostname_binding"
  for_each = { for k, v in var.custom_domains : k => v if !v.slot_as_target }

  hostname   = each.value.hostname
  parent_id  = azapi_resource.this.id
  retry      = var.retry
  ssl_state  = each.value.ssl_state
  thumbprint = each.value.thumbprint
}

module "slot_hostname_binding" {
  source   = "./modules/hostname_binding"
  for_each = { for k, v in var.custom_domains : k => v if v.slot_as_target }

  hostname   = each.value.hostname
  parent_id  = module.slot[each.value.app_service_slot_key].resource_id
  retry      = var.retry
  ssl_state  = each.value.ssl_state
  thumbprint = each.value.thumbprint
}
