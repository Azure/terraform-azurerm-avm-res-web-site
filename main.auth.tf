# Deprecated but kept for backward compatibility.
module "config_authsettings" {
  source   = "./modules/config_authsettings"
  for_each = var.auth_settings

  parent_id                      = azapi_resource.this.id
  enabled                        = each.value.enabled
  runtime_version                = each.value.runtime_version
  token_store_enabled            = each.value.token_store_enabled
  token_refresh_extension_hours  = each.value.token_refresh_extension_hours
  unauthenticated_client_action  = each.value.unauthenticated_client_action
  issuer                         = each.value.issuer
  allowed_external_redirect_urls = each.value.allowed_external_redirect_urls
  additional_login_parameters    = each.value.additional_login_parameters
  default_provider               = each.value.default_provider
  active_directory               = length(each.value.active_directory) > 0 ? values(each.value.active_directory)[0] : null
  facebook                       = length(each.value.facebook) > 0 ? values(each.value.facebook)[0] : null
  github                         = length(each.value.github) > 0 ? values(each.value.github)[0] : null
  google                         = length(each.value.google) > 0 ? values(each.value.google)[0] : null
  microsoft                      = length(each.value.microsoft) > 0 ? values(each.value.microsoft)[0] : null
  twitter                        = length(each.value.twitter) > 0 ? values(each.value.twitter)[0] : null
}

module "config_authsettingsv2" {
  source   = "./modules/config_authsettingsv2"
  for_each = var.auth_settings_v2

  parent_id                               = azapi_resource.this.id
  auth_enabled                            = each.value.auth_enabled
  config_file_path                        = each.value.config_file_path
  require_authentication                  = each.value.require_authentication
  unauthenticated_action                  = each.value.unauthenticated_action
  excluded_paths                          = each.value.excluded_paths
  require_https                           = each.value.require_https
  http_route_api_prefix                   = each.value.http_route_api_prefix
  forward_proxy_convention                = each.value.forward_proxy_convention
  forward_proxy_custom_host_header_name   = each.value.forward_proxy_custom_host_header_name
  forward_proxy_custom_scheme_header_name = each.value.forward_proxy_custom_scheme_header_name
  runtime_version                         = each.value.runtime_version
  active_directory_v2                     = each.value.active_directory_v2
  login                                   = each.value.login
}
