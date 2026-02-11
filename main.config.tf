module "config_appsettings" {
  source   = "./modules/config_appsettings"
  for_each = length(local.merged_app_settings) > 0 ? { "default" = {} } : {}

  app_settings = local.merged_app_settings
  parent_id    = azapi_resource.this.id
}

module "config_connectionstrings" {
  source   = "./modules/config_connectionstrings"
  for_each = length(var.connection_strings) > 0 ? { "default" = {} } : {}

  connection_strings = var.connection_strings
  parent_id          = azapi_resource.this.id
}

module "config_azurestorageaccounts" {
  source   = "./modules/config_azurestorageaccounts"
  for_each = length(var.storage_shares_to_mount) > 0 ? { "default" = {} } : {}

  parent_id               = azapi_resource.this.id
  storage_shares_to_mount = var.storage_shares_to_mount
}

module "config_slotconfignames" {
  source   = "./modules/config_slotconfignames"
  for_each = length(var.sticky_settings) > 0 ? { "default" = {} } : {}

  parent_id               = azapi_resource.this.id
  app_setting_names       = flatten([for k, v in var.sticky_settings : coalesce(v.app_setting_names, [])])
  connection_string_names = flatten([for k, v in var.sticky_settings : coalesce(v.connection_string_names, [])])
}

module "ftp_publishing_credential_policy" {
  source   = "./modules/publishing_credential_policy"
  for_each = !var.ftp_publish_basic_authentication_enabled ? { "default" = {} } : {}

  name      = "ftp"
  parent_id = azapi_resource.this.id
  allow     = false
}

module "scm_publishing_credential_policy" {
  source   = "./modules/publishing_credential_policy"
  for_each = !var.scm_publish_basic_authentication_enabled ? { "default" = {} } : {}

  name      = "scm"
  parent_id = azapi_resource.this.id
  allow     = false
}
