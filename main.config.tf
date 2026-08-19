module "config_appsettings" {
  source = "./modules/config_appsettings"

  app_settings        = local.merged_app_settings
  parent_id           = azapi_resource.this.id
  ignore_body_changes = var.ignore_body_changes.config_appsettings
  resource_types      = var.resource_types.config_appsettings
  retry               = var.retry
  timeouts            = var.timeouts
}

module "config_connectionstrings" {
  source = "./modules/config_connectionstrings"

  connection_strings  = var.connection_strings
  parent_id           = azapi_resource.this.id
  ignore_body_changes = var.ignore_body_changes.config_connectionstrings
  resource_types      = var.resource_types.config_connectionstrings
  retry               = var.retry
  timeouts            = var.timeouts
}

module "config_azurestorageaccounts" {
  source = "./modules/config_azurestorageaccounts"

  parent_id               = azapi_resource.this.id
  storage_shares_to_mount = var.storage_shares_to_mount
  ignore_body_changes     = var.ignore_body_changes.config_azurestorageaccounts
  resource_types          = var.resource_types.config_azurestorageaccounts
  retry                   = var.retry
  timeouts                = var.timeouts
}

module "config_metadata" {
  source = "./modules/config_metadata"

  metadata            = { for m in coalesce(module.site_config_helpers.site_config_metadata, []) : m.name => m.value }
  parent_id           = azapi_resource.this.id
  ignore_body_changes = var.ignore_body_changes.config_metadata
  resource_types      = var.resource_types.config_metadata
  retry               = var.retry
  timeouts            = var.timeouts
}

module "config_slotconfignames" {
  source   = "./modules/config_slotconfignames"
  for_each = length(var.sticky_settings) > 0 ? { "default" = {} } : {}

  parent_id               = azapi_resource.this.id
  app_setting_names       = flatten([for k, v in var.sticky_settings : coalesce(v.app_setting_names, [])])
  connection_string_names = flatten([for k, v in var.sticky_settings : coalesce(v.connection_string_names, [])])
  ignore_body_changes     = var.ignore_body_changes.config_slotconfignames
  resource_types          = var.resource_types.config_slotconfignames
  retry                   = var.retry
  timeouts                = var.timeouts
}

module "ftp_publishing_credential_policy" {
  source   = "./modules/publishing_credential_policy"
  for_each = !var.ftp_publish_basic_authentication_enabled ? { "default" = {} } : {}

  name                = "ftp"
  parent_id           = azapi_resource.this.id
  allow               = false
  ignore_body_changes = var.ignore_body_changes.publishing_credential_policy
  resource_types      = var.resource_types.publishing_credential_policy
  retry               = var.retry
  timeouts            = var.timeouts
}

module "scm_publishing_credential_policy" {
  source   = "./modules/publishing_credential_policy"
  for_each = !var.scm_publish_basic_authentication_enabled ? { "default" = {} } : {}

  name                = "scm"
  parent_id           = azapi_resource.this.id
  allow               = false
  ignore_body_changes = var.ignore_body_changes.publishing_credential_policy
  resource_types      = var.resource_types.publishing_credential_policy
  retry               = var.retry
  timeouts            = var.timeouts
}
