variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}

variable "active_directory_v2" {
  type = map(object({
    allowed_applications                 = optional(list(string))
    allowed_audiences                    = optional(list(string))
    allowed_groups                       = optional(list(string))
    allowed_identities                   = optional(list(string))
    client_id                            = optional(string)
    client_secret_certificate_thumbprint = optional(string)
    client_secret_setting_name           = optional(string)
    jwt_allowed_client_applications      = optional(list(string))
    jwt_allowed_groups                   = optional(list(string))
    login_parameters                     = optional(map(any))
    tenant_auth_endpoint                 = optional(string)
    www_authentication_disabled          = optional(bool, false)
  }))
  default     = {}
  description = <<DESCRIPTION
Active Directory V2 authentication configuration.

- `allowed_applications` - (Optional) A list of allowed application IDs.
- `allowed_audiences` - (Optional) A list of allowed audience values.
- `allowed_groups` - (Optional) A list of allowed group IDs.
- `allowed_identities` - (Optional) A list of allowed identity values.
- `client_id` - (Optional) The Client ID.
- `client_secret_certificate_thumbprint` - (Optional) The thumbprint of the client secret certificate.
- `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
- `jwt_allowed_client_applications` - (Optional) A list of allowed JWT client applications.
- `jwt_allowed_groups` - (Optional) A list of allowed JWT groups.
- `login_parameters` - (Optional) A map of login parameters.
- `tenant_auth_endpoint` - (Optional) The tenant authentication endpoint.
- `www_authentication_disabled` - (Optional) Should WWW-Authenticate be disabled? Defaults to `false`.
DESCRIPTION
}

variable "auth_enabled" {
  type        = bool
  default     = false
  description = "Is authentication enabled? Defaults to `false`."
}

variable "config_file_path" {
  type        = string
  default     = null
  description = "The path to the auth configuration file."
}

variable "default_provider" {
  type        = string
  default     = null
  description = "The default authentication provider."
}

variable "excluded_paths" {
  type        = list(string)
  default     = null
  description = "A list of paths excluded from authentication."
}

variable "forward_proxy_convention" {
  type        = string
  default     = "NoProxy"
  description = "The convention for forwarding proxy headers. Defaults to `NoProxy`."
}

variable "forward_proxy_custom_host_header_name" {
  type        = string
  default     = null
  description = "The custom host header name for the forward proxy."
}

variable "forward_proxy_custom_scheme_header_name" {
  type        = string
  default     = null
  description = "The custom scheme header name for the forward proxy."
}

variable "http_route_api_prefix" {
  type        = string
  default     = "/.auth"
  description = "The prefix for the HTTP route API. Defaults to `/.auth`."
}

variable "login" {
  type = map(object({
    allowed_external_redirect_urls    = optional(list(string))
    cookie_expiration_convention      = optional(string, "FixedTime")
    cookie_expiration_time            = optional(string, "08:00:00")
    logout_endpoint                   = optional(string)
    nonce_expiration_time             = optional(string, "00:05:00")
    preserve_url_fragments_for_logins = optional(bool, false)
    token_refresh_extension_time      = optional(number, 72)
    token_store_enabled               = optional(bool, false)
    token_store_path                  = optional(string)
    token_store_sas_setting_name      = optional(string)
    validate_nonce                    = optional(bool, true)
  }))
  default     = {}
  description = <<DESCRIPTION
Login configuration for auth settings V2.

- `allowed_external_redirect_urls` - (Optional) A list of allowed external redirect URLs.
- `cookie_expiration_convention` - (Optional) The cookie expiration convention. Defaults to `FixedTime`.
- `cookie_expiration_time` - (Optional) The cookie expiration time. Defaults to `08:00:00`.
- `logout_endpoint` - (Optional) The logout endpoint.
- `nonce_expiration_time` - (Optional) The nonce expiration time. Defaults to `00:05:00`.
- `preserve_url_fragments_for_logins` - (Optional) Should URL fragments be preserved for logins? Defaults to `false`.
- `token_refresh_extension_time` - (Optional) Hours before token expiry to refresh. Defaults to `72`.
- `token_store_enabled` - (Optional) Should the token store be enabled? Defaults to `false`.
- `token_store_path` - (Optional) The path to the token store.
- `token_store_sas_setting_name` - (Optional) The app setting name that contains the token store SAS URL.
- `validate_nonce` - (Optional) Should the nonce be validated? Defaults to `true`.
DESCRIPTION
}

variable "require_authentication" {
  type        = bool
  default     = false
  description = "Should authentication be required? Defaults to `false`."
}

variable "require_https" {
  type        = bool
  default     = true
  description = "Should HTTPS be required? Defaults to `true`."
}

variable "runtime_version" {
  type        = string
  default     = "~1"
  description = "The runtime version of the auth module. Defaults to `~1`."
}

variable "unauthenticated_action" {
  type        = string
  default     = "RedirectToLoginPage"
  description = "The action for unauthenticated requests. Defaults to `RedirectToLoginPage`."
}
