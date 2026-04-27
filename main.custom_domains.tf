module "certificate" {
  source   = "./modules/certificate"
  for_each = var.certificates

  location              = var.location
  name                  = coalesce(each.value.name, each.key)
  parent_id             = var.parent_id
  server_farm_id        = var.service_plan_resource_id
  host_names            = each.value.host_names
  key_vault_id          = each.value.key_vault_id
  key_vault_secret_name = each.value.key_vault_secret_name
  password              = each.value.password
  pfx_blob              = each.value.pfx_blob
  retry                 = var.retry
  tags                  = each.value.tags
}

module "hostname_binding" {
  source   = "./modules/hostname_binding"
  for_each = var.custom_domains

  hostname   = each.value.hostname
  parent_id  = azapi_resource.this.id
  retry      = var.retry
  ssl_state  = each.value.ssl_state
  thumbprint = each.value.certificate_key != null ? module.certificate[each.value.certificate_key].thumbprint : each.value.thumbprint
}

locals {
  slot_custom_domains = merge([
    for slot_key, slot in var.deployment_slots : {
      for domain_key, domain in slot.custom_domains :
      "${slot_key}-${domain_key}" => {
        slot_key        = slot_key
        hostname        = domain.hostname
        ssl_state       = domain.ssl_state
        thumbprint      = domain.thumbprint
        certificate_key = domain.certificate_key
      }
    }
  ]...)
}

module "slot_hostname_binding" {
  source   = "./modules/hostname_binding"
  for_each = local.slot_custom_domains

  hostname   = each.value.hostname
  parent_id  = module.slot[each.value.slot_key].resource_id
  retry      = var.retry
  ssl_state  = each.value.ssl_state
  thumbprint = each.value.certificate_key != null ? module.certificate[each.value.certificate_key].thumbprint : each.value.thumbprint
}
