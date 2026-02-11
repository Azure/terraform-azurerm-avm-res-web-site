# Deprecated but kept for backward compatibility.
module "config_authsettings" {
  source   = "./modules/config_authsettings"
  for_each = var.auth_settings

  parent_id                      = azapi_resource.this.id
  active_directory               = length(each.value.active_directory) > 0 ? values(each.value.active_directory)[0] : null
  additional_login_parameters    = each.value.additional_login_parameters
  allowed_external_redirect_urls = each.value.allowed_external_redirect_urls
  default_provider               = each.value.default_provider
  enabled                        = each.value.enabled
  facebook                       = length(each.value.facebook) > 0 ? values(each.value.facebook)[0] : null
  github                         = length(each.value.github) > 0 ? values(each.value.github)[0] : null
  google                         = length(each.value.google) > 0 ? values(each.value.google)[0] : null
  issuer                         = each.value.issuer
  microsoft                      = length(each.value.microsoft) > 0 ? values(each.value.microsoft)[0] : null
  runtime_version                = each.value.runtime_version
  token_refresh_extension_hours  = each.value.token_refresh_extension_hours
  token_store_enabled            = each.value.token_store_enabled
  twitter                        = length(each.value.twitter) > 0 ? values(each.value.twitter)[0] : null
  unauthenticated_client_action  = each.value.unauthenticated_client_action
}

module "config_authsettingsv2" {
  source   = "./modules/config_authsettingsv2"
  for_each = var.auth_settings_v2

  parent_id                               = azapi_resource.this.id
  active_directory_v2                     = each.value.active_directory_v2
  auth_enabled                            = each.value.auth_enabled
  config_file_path                        = each.value.config_file_path
  excluded_paths                          = each.value.excluded_paths
  forward_proxy_convention                = each.value.forward_proxy_convention
  forward_proxy_custom_host_header_name   = each.value.forward_proxy_custom_host_header_name
  forward_proxy_custom_scheme_header_name = each.value.forward_proxy_custom_scheme_header_name
  http_route_api_prefix                   = each.value.http_route_api_prefix
  login                                   = each.value.login
  require_authentication                  = each.value.require_authentication
  require_https                           = each.value.require_https
  runtime_version                         = each.value.runtime_version
  unauthenticated_action                  = each.value.unauthenticated_action
}
