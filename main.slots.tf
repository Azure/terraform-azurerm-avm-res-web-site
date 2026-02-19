module "slot" {
  source   = "./modules/slot"
  for_each = var.deployment_slots

  kind                     = local.arm_kind
  location                 = var.location
  name                     = coalesce(each.value.name, each.key)
  os_type                  = var.os_type
  parent_id                = azapi_resource.this.id
  service_plan_resource_id = var.service_plan_resource_id
  # App settings and config
  app_settings                           = each.value.app_settings
  application_insights_connection_string = var.application_insights_connection_string
  application_insights_key               = var.application_insights_key
  # Slot-specific properties
  auto_generated_domain_name_label_scope   = each.value.auto_generated_domain_name_label_scope
  client_affinity_enabled                  = each.value.client_affinity_enabled
  client_affinity_partitioning_enabled     = each.value.client_affinity_partitioning_enabled
  client_affinity_proxy_enabled            = each.value.client_affinity_proxy_enabled
  client_certificate_enabled               = each.value.client_certificate_enabled
  client_certificate_exclusion_paths       = each.value.client_certificate_exclusion_paths
  client_certificate_mode                  = each.value.client_certificate_mode
  connection_strings                       = each.value.connection_strings
  container_size                           = each.value.container_size
  dapr_config                              = each.value.dapr_config
  dns_configuration                        = each.value.dns_configuration
  enabled                                  = each.value.enabled
  end_to_end_encryption_enabled            = each.value.end_to_end_encryption_enabled
  ftp_publish_basic_authentication_enabled = each.value.ftp_publish_basic_authentication_enabled
  function_app_uses_fc1                    = var.function_app_uses_fc1
  host_names_disabled                      = each.value.host_names_disabled
  hosting_environment_id                   = each.value.hosting_environment_id
  https_only                               = each.value.https_only
  hyper_v                                  = each.value.hyper_v
  ip_mode                                  = each.value.ip_mode
  is_function_app                          = local.is_function_app
  key_vault_reference_identity             = each.value.key_vault_reference_identity
  # AVM interfaces
  lock = each.value.lock != null ? each.value.lock : (
    var.deployment_slots_inherit_lock && var.lock != null ? var.lock : null
  )
  managed_environment_id                  = each.value.managed_environment_id
  managed_identities                      = var.managed_identities
  private_endpoints                       = each.value.private_endpoints
  private_endpoints_inherit_lock          = var.private_endpoints_inherit_lock
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  public_network_access_enabled           = each.value.public_network_access_enabled
  redundancy_mode                         = each.value.redundancy_mode
  resource_config                         = each.value.resource_config
  role_assignments                        = each.value.role_assignments
  scm_site_also_stopped                   = each.value.scm_site_also_stopped
  sensitive_app_settings                  = lookup(var.slot_sensitive_app_settings, each.key, {})
  server_farm_id                          = each.value.server_farm_id
  # Site config
  site_config              = each.value.site_config
  ssh_enabled              = each.value.ssh_enabled
  storage_account_required = each.value.storage_account_required
  storage_shares_access_keys = {
    for k, v in each.value.storage_shares_to_mount : k => var.slots_storage_shares_to_mount_sensitive_values[k]
  }
  storage_shares_to_mount                        = each.value.storage_shares_to_mount
  tags                                           = var.all_child_resources_inherit_tags ? merge(var.tags, each.value.tags) : each.value.tags
  virtual_network_subnet_id                      = each.value.virtual_network_subnet_id
  vnet_application_traffic_enabled               = each.value.vnet_application_traffic_enabled
  vnet_backup_restore_enabled                    = each.value.vnet_backup_restore_enabled
  vnet_content_share_enabled                     = each.value.vnet_content_share_enabled
  vnet_image_pull_enabled                        = each.value.vnet_image_pull_enabled
  vnet_route_all_traffic                         = each.value.vnet_route_all_traffic
  webdeploy_publish_basic_authentication_enabled = each.value.webdeploy_publish_basic_authentication_enabled
  workload_profile_name                          = each.value.workload_profile_name
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
