resource "azapi_update_resource" "this" {
  name      = "authsettingsV2"
  parent_id = var.parent_id
  type      = var.resource_types.web_sites_config
  body = {
    properties = merge(
      {
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
      },
      local.login != null ? {
        login = local.login
      } : {},
    )
  }
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
