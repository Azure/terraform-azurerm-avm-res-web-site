resource "azapi_update_resource" "this" {
  name      = "authsettingsV2"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      platform = {
        enabled        = var.auth_enabled
        runtimeVersion = var.runtime_version
        configFilePath = var.config_file_path
      }
      globalValidation = {
        excludedPaths               = var.excluded_paths
        redirectToProvider          = var.redirect_to_provider
        requireAuthentication       = var.require_authentication
        unauthenticatedClientAction = var.unauthenticated_client_action
      }
      httpSettings      = local.http_settings
      identityProviders = local.identity_providers
      login             = local.login
    }
  }
  response_export_values = []
}
