variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}

variable "enabled" {
  type        = bool
  default     = false
  description = "Is authentication enabled? Defaults to `false`."
}

variable "runtime_version" {
  type        = string
  default     = null
  description = "The runtime version of the authentication module."
}

variable "token_store_enabled" {
  type        = bool
  default     = false
  description = "Should the token store be enabled? Defaults to `false`."
}

variable "token_refresh_extension_hours" {
  type        = number
  default     = 72
  description = "Hours before token expiry to refresh. Defaults to `72`."
}

variable "unauthenticated_client_action" {
  type        = string
  default     = null
  description = "The action to take for unauthenticated requests."
}

variable "issuer" {
  type        = string
  default     = null
  description = "The issuer URI."
}

variable "allowed_external_redirect_urls" {
  type        = list(string)
  default     = null
  description = "A list of allowed external redirect URLs."
}

variable "additional_login_parameters" {
  type        = map(string)
  default     = null
  description = "A map of additional login parameters."
}

variable "default_provider" {
  type        = string
  default     = null
  description = "The default authentication provider."
}

variable "active_directory" {
  type = object({
    client_id                  = optional(string)
    allowed_audiences          = optional(list(string))
    client_secret              = optional(string)
    client_secret_setting_name = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Active Directory authentication configuration.

- `client_id` - (Optional) The Client ID of the Azure AD application.
- `allowed_audiences` - (Optional) A list of allowed audience values.
- `client_secret` - (Optional) The Client Secret of the Azure AD application.
- `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
DESCRIPTION
}

variable "facebook" {
  type = object({
    app_id                  = optional(string)
    app_secret              = optional(string)
    app_secret_setting_name = optional(string)
    oauth_scopes            = optional(list(string))
  })
  default     = null
  description = <<DESCRIPTION
Facebook authentication configuration.

- `app_id` - (Optional) The App ID of the Facebook application.
- `app_secret` - (Optional) The App Secret of the Facebook application.
- `app_secret_setting_name` - (Optional) The app setting name that contains the app secret.
- `oauth_scopes` - (Optional) A list of OAuth scopes to request.
DESCRIPTION
}

variable "github" {
  type = object({
    client_id                  = optional(string)
    client_secret              = optional(string)
    client_secret_setting_name = optional(string)
    oauth_scopes               = optional(list(string))
  })
  default     = null
  description = <<DESCRIPTION
GitHub authentication configuration.

- `client_id` - (Optional) The Client ID of the GitHub application.
- `client_secret` - (Optional) The Client Secret of the GitHub application.
- `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
- `oauth_scopes` - (Optional) A list of OAuth scopes to request.
DESCRIPTION
}

variable "google" {
  type = object({
    client_id                  = optional(string)
    client_secret              = optional(string)
    client_secret_setting_name = optional(string)
    oauth_scopes               = optional(list(string))
  })
  default     = null
  description = <<DESCRIPTION
Google authentication configuration.

- `client_id` - (Optional) The Client ID of the Google application.
- `client_secret` - (Optional) The Client Secret of the Google application.
- `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
- `oauth_scopes` - (Optional) A list of OAuth scopes to request.
DESCRIPTION
}

variable "microsoft" {
  type = object({
    client_id                  = optional(string)
    client_secret              = optional(string)
    client_secret_setting_name = optional(string)
    oauth_scopes               = optional(list(string))
  })
  default     = null
  description = <<DESCRIPTION
Microsoft authentication configuration.

- `client_id` - (Optional) The Client ID of the Microsoft application.
- `client_secret` - (Optional) The Client Secret of the Microsoft application.
- `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
- `oauth_scopes` - (Optional) A list of OAuth scopes to request.
DESCRIPTION
}

variable "twitter" {
  type = object({
    consumer_key                 = optional(string)
    consumer_secret              = optional(string)
    consumer_secret_setting_name = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Twitter authentication configuration.

- `consumer_key` - (Optional) The consumer key of the Twitter application.
- `consumer_secret` - (Optional) The consumer secret of the Twitter application.
- `consumer_secret_setting_name` - (Optional) The app setting name that contains the consumer secret.
DESCRIPTION
}
