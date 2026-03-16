resource "time_sleep" "wait_for_app_settings" {
  for_each = var.zip_deploy_file != null ? { "default" = {} } : {}

  create_duration = var.zip_deploy_wait_duration

  depends_on = [
    module.config_appsettings,
    module.config_connectionstrings,
  ]
}

module "extensions_zipdeploy" {
  source   = "./modules/extensions_zipdeploy"
  for_each = var.zip_deploy_file != null ? { "default" = {} } : {}

  parent_id       = azapi_resource.this.id
  zip_deploy_file = var.zip_deploy_file

  depends_on = [
    time_sleep.wait_for_app_settings,
  ]
}
