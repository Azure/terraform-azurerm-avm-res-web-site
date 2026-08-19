# Deprecated but kept for backward compatibility.
# Auth v1 settings cannot be applied when auth v2 is also configured.
module "config_authsettings" {
  source   = "./modules/config_authsettings"
  for_each = var.auth_settings != null && var.auth_settings_v2 == null ? { this = var.auth_settings } : {}

  parent_id                      = azapi_resource.this.id
  active_directory               = each.value.active_directory
  additional_login_parameters    = each.value.additional_login_parameters
  allowed_external_redirect_urls = each.value.allowed_external_redirect_urls
  default_provider               = each.value.default_provider
  enabled                        = each.value.enabled
  facebook                       = each.value.facebook
  github                         = each.value.github
  google                         = each.value.google
  ignore_body_changes            = var.ignore_body_changes.config_authsettings
  issuer                         = each.value.issuer
  microsoft                      = each.value.microsoft
  resource_types                 = var.resource_types.config_authsettings
  retry                          = var.retry
  runtime_version                = each.value.runtime_version
  timeouts                       = var.timeouts
  token_refresh_extension_hours  = each.value.token_refresh_extension_hours
  token_store_enabled            = each.value.token_store_enabled
  twitter                        = each.value.twitter
  unauthenticated_client_action  = each.value.unauthenticated_client_action
}

module "config_authsettingsv2" {
  source   = "./modules/config_authsettingsv2"
  for_each = var.auth_settings_v2 != null ? { this = var.auth_settings_v2 } : {}

  parent_id                              = azapi_resource.this.id
  auth_enabled                           = each.value.auth_enabled
  config_file_path                       = each.value.config_file_path
  excluded_paths                         = each.value.excluded_paths
  forward_proxy_convention               = each.value.forward_proxy_convention
  forward_proxy_custom_host_header_name  = each.value.forward_proxy_custom_host_header_name
  forward_proxy_custom_proto_header_name = each.value.forward_proxy_custom_proto_header_name
  http_route_api_prefix                  = each.value.http_route_api_prefix
  identity_providers                     = each.value.identity_providers
  ignore_body_changes                    = var.ignore_body_changes.config_authsettingsv2
  login                                  = each.value.login
  redirect_to_provider                   = each.value.redirect_to_provider
  require_authentication                 = each.value.require_authentication
  require_https                          = each.value.require_https
  resource_types                         = var.resource_types.config_authsettingsv2
  retry                                  = var.retry
  runtime_version                        = each.value.runtime_version
  timeouts                               = var.timeouts
  unauthenticated_client_action          = each.value.unauthenticated_client_action
}
