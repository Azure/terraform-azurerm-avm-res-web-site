module "slot" {
  source   = "./modules/slot"
  for_each = var.deployment_slots

  parent_id                = azapi_resource.this.id
  name                     = coalesce(each.value.name, each.key)
  location                 = var.location
  kind                     = local.arm_kind
  os_type                  = var.os_type
  is_function_app          = local.is_function_app
  is_web_app               = local.is_web_app
  service_plan_resource_id = var.service_plan_resource_id
  tags                     = var.all_child_resources_inherit_tags ? merge(var.tags, each.value.tags) : each.value.tags
  managed_identities       = var.managed_identities

  # Slot-specific properties
  client_affinity_enabled            = each.value.client_affinity_enabled
  client_certificate_enabled         = each.value.client_certificate_enabled
  client_certificate_exclusion_paths = each.value.client_certificate_exclusion_paths
  client_certificate_mode            = each.value.client_certificate_mode
  enabled                            = each.value.enabled
  https_only                         = each.value.https_only
  key_vault_reference_identity_id    = each.value.key_vault_reference_identity_id
  public_network_access_enabled      = each.value.public_network_access_enabled
  service_plan_id                    = each.value.service_plan_id
  virtual_network_subnet_id          = each.value.virtual_network_subnet_id

  ftp_publish_basic_authentication_enabled       = each.value.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = each.value.webdeploy_publish_basic_authentication_enabled

  # Site config
  site_config = each.value.site_config

  # App settings and config
  app_settings            = each.value.app_settings
  additional_app_settings = lookup(var.slot_app_settings, each.key, {})

  enable_application_insights            = var.enable_application_insights
  application_insights_connection_string = try(azapi_resource.application_insights[0].output.properties.ConnectionString, null)
  application_insights_key               = try(azapi_resource.application_insights[0].output.properties.InstrumentationKey, null)

  connection_strings      = each.value.connection_strings
  storage_shares_to_mount = each.value.storage_shares_to_mount
  storage_shares_access_keys = {
    for k, v in each.value.storage_shares_to_mount : k => var.slots_storage_shares_to_mount_sensitive_values[k]
  }

  # AVM interfaces
  lock = each.value.lock != null ? each.value.lock : (
    var.deployment_slots_inherit_lock && var.lock != null ? var.lock : null
  )
  role_assignments                        = each.value.role_assignments
  private_endpoints                       = each.value.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  private_endpoints_inherit_lock          = var.private_endpoints_inherit_lock
}

resource "azapi_resource_action" "active_slot" {
  count = var.app_service_active_slot != null ? 1 : 0

  action      = "slotsswap"
  method      = "POST"
  resource_id = azapi_resource.this.id
  type        = "Microsoft.Web/sites@2025-03-01"
  body = {
    targetSlot   = coalesce(var.deployment_slots[var.app_service_active_slot.slot_key].name, var.app_service_active_slot.slot_key)
    preserveVnet = !var.app_service_active_slot.overwrite_network_config
  }

  depends_on = [module.slot]
}
