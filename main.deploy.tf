resource "time_sleep" "wait_before_zip_deploy" {
  for_each = var.zip_deploy_file != null ? { "default" = {} } : {}

  create_duration = var.zip_deploy_wait_duration

  depends_on = [
    module.config_appsettings,
    module.config_connectionstrings,
    module.config_azurestorageaccounts,
    module.config_metadata,
    module.config_slotconfignames,
    module.ftp_publishing_credential_policy,
    module.scm_publishing_credential_policy,
  ]
}

module "extensions_zipdeploy" {
  source   = "./modules/extensions_zipdeploy"
  for_each = var.zip_deploy_file != null ? { "default" = {} } : {}

  parent_id           = azapi_resource.this.id
  zip_deploy_file     = var.zip_deploy_file
  ignore_body_changes = var.ignore_body_changes.extensions_zipdeploy
  resource_types      = var.resource_types.extensions_zipdeploy
  retry               = var.retry
  timeouts            = var.timeouts

  depends_on = [
    time_sleep.wait_before_zip_deploy,
  ]
}
