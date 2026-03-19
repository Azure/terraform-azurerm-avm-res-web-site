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

  parent_id       = azapi_resource.this.id
  zip_deploy_file = var.zip_deploy_file
  retry           = var.retry

  depends_on = [
    time_sleep.wait_before_zip_deploy,
  ]
}
