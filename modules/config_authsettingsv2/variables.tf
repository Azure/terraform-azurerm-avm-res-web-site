variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
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

variable "forward_proxy_custom_proto_header_name" {
  type        = string
  default     = null
  description = "The custom proto header name for the forward proxy."
}

variable "http_route_api_prefix" {
  type        = string
  default     = "/.auth"
  description = "The prefix for the HTTP route API. Defaults to `/.auth`."
}

variable "identity_providers" {
  type = object({
    apple = optional(object({
      enabled = optional(bool)
      login = optional(object({
        scopes = optional(list(string))
      }))
      registration = optional(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
      }))
    }))
    azure_active_directory = optional(object({
      enabled             = optional(bool)
      is_auto_provisioned = optional(bool)
      login = optional(object({
        disable_www_authenticate = optional(bool)
        login_parameters         = optional(list(string))
      }))
      registration = optional(object({
        client_id                                          = optional(string)
        client_secret_certificate_issuer                   = optional(string)
        client_secret_certificate_subject_alternative_name = optional(string)
        client_secret_certificate_thumbprint               = optional(string)
        client_secret_setting_name                         = optional(string)
        open_id_issuer                                     = optional(string)
      }))
      validation = optional(object({
        allowed_audiences = optional(list(string))
        default_authorization_policy = optional(object({
          allowed_applications = optional(list(string))
          allowed_principals = optional(object({
            groups     = optional(list(string))
            identities = optional(list(string))
          }))
        }))
        jwt_claim_checks = optional(object({
          allowed_client_applications = optional(list(string))
          allowed_groups              = optional(list(string))
        }))
      }))
    }))
    azure_static_web_apps = optional(object({
      enabled = optional(bool)
      registration = optional(object({
        client_id = optional(string)
      }))
    }))
    custom_open_id_connect_providers = optional(map(object({
      enabled = optional(bool)
      login = optional(object({
        name_claim_type = optional(string)
        scopes          = optional(list(string))
      }))
      registration = optional(object({
        client_id = optional(string)
        client_credential = optional(object({
          method                     = optional(string)
          client_secret_setting_name = optional(string)
        }))
        open_id_connect_configuration = optional(object({
          authorization_endpoint           = optional(string)
          certification_uri                = optional(string)
          issuer                           = optional(string)
          token_endpoint                   = optional(string)
          well_known_open_id_configuration = optional(string)
        }))
      }))
    })))
    facebook = optional(object({
      enabled           = optional(bool)
      graph_api_version = optional(string)
      login = optional(object({
        scopes = optional(list(string))
      }))
      registration = optional(object({
        app_id                  = optional(string)
        app_secret_setting_name = optional(string)
      }))
    }))
    github = optional(object({
      enabled = optional(bool)
      login = optional(object({
        scopes = optional(list(string))
      }))
      registration = optional(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
      }))
    }))
    google = optional(object({
      enabled = optional(bool)
      login = optional(object({
        scopes = optional(list(string))
      }))
      registration = optional(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
      }))
      validation = optional(object({
        allowed_audiences = optional(list(string))
      }))
    }))
    legacy_microsoft_account = optional(object({
      enabled = optional(bool)
      login = optional(object({
        scopes = optional(list(string))
      }))
      registration = optional(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
      }))
      validation = optional(object({
        allowed_audiences = optional(list(string))
      }))
    }))
    twitter = optional(object({
      enabled = optional(bool)
      registration = optional(object({
        consumer_key                 = optional(string)
        consumer_secret_setting_name = optional(string)
      }))
    }))
  })
  default     = null
  description = <<DESCRIPTION
The identity providers configuration for authentication. This mirrors the API structure of `identityProviders`.

- `apple` - (Optional) The Apple provider configuration.
  - `enabled` - (Optional) Whether the Apple provider is enabled.
  - `login` - (Optional) The login configuration.
    - `scopes` - (Optional) A list of scopes.
  - `registration` - (Optional) The registration configuration.
    - `client_id` - (Optional) The Client ID.
    - `client_secret_setting_name` - (Optional) The app setting name containing the client secret.
- `azure_active_directory` - (Optional) The Azure Active Directory provider configuration.
  - `enabled` - (Optional) Whether the Azure AD provider is enabled.
  - `is_auto_provisioned` - (Optional) Whether the Azure AD configuration was auto-provisioned.
  - `login` - (Optional) The login configuration.
    - `disable_www_authenticate` - (Optional) Whether to disable WWW-Authenticate.
    - `login_parameters` - (Optional) Login parameters as a list of "key=value" strings.
  - `registration` - (Optional) The registration configuration.
    - `client_id` - (Optional) The Client ID.
    - `client_secret_certificate_issuer` - (Optional) The certificate issuer for the client secret.
    - `client_secret_certificate_subject_alternative_name` - (Optional) The certificate subject alternative name.
    - `client_secret_certificate_thumbprint` - (Optional) The certificate thumbprint for the client secret.
    - `client_secret_setting_name` - (Optional) The app setting name containing the client secret.
    - `open_id_issuer` - (Optional) The OpenID Connect issuer URI.
  - `validation` - (Optional) The validation configuration.
    - `allowed_audiences` - (Optional) A list of allowed audiences.
    - `default_authorization_policy` - (Optional) The default authorization policy.
      - `allowed_applications` - (Optional) A list of allowed applications.
      - `allowed_principals` - (Optional) The allowed principals.
        - `groups` - (Optional) A list of allowed groups.
        - `identities` - (Optional) A list of allowed identities.
    - `jwt_claim_checks` - (Optional) JWT claim check configuration.
      - `allowed_client_applications` - (Optional) A list of allowed client applications.
      - `allowed_groups` - (Optional) A list of allowed groups.
- `azure_static_web_apps` - (Optional) The Azure Static Web Apps provider configuration.
  - `enabled` - (Optional) Whether the provider is enabled.
  - `registration` - (Optional) The registration configuration.
    - `client_id` - (Optional) The Client ID.
- `custom_open_id_connect_providers` - (Optional) A map of custom OpenID Connect providers.
  - `enabled` - (Optional) Whether the provider is enabled.
  - `login` - (Optional) The login configuration.
    - `name_claim_type` - (Optional) The name claim type.
    - `scopes` - (Optional) A list of scopes.
  - `registration` - (Optional) The registration configuration.
    - `client_id` - (Optional) The Client ID.
    - `client_credential` - (Optional) The client credential configuration.
      - `method` - (Optional) The client credential method.
      - `client_secret_setting_name` - (Optional) The app setting name containing the client secret.
    - `open_id_connect_configuration` - (Optional) The OpenID Connect configuration.
      - `authorization_endpoint` - (Optional) The authorization endpoint.
      - `certification_uri` - (Optional) The certification URI.
      - `issuer` - (Optional) The issuer endpoint.
      - `token_endpoint` - (Optional) The token endpoint.
      - `well_known_open_id_configuration` - (Optional) The well-known OpenID configuration endpoint.
- `facebook` - (Optional) The Facebook provider configuration.
  - `enabled` - (Optional) Whether the provider is enabled.
  - `graph_api_version` - (Optional) The Graph API version.
  - `login` - (Optional) The login configuration.
    - `scopes` - (Optional) A list of scopes.
  - `registration` - (Optional) The registration configuration.
    - `app_id` - (Optional) The App ID.
    - `app_secret_setting_name` - (Optional) The app setting name containing the app secret.
- `github` - (Optional) The GitHub provider configuration.
  - `enabled` - (Optional) Whether the provider is enabled.
  - `login` - (Optional) The login configuration.
    - `scopes` - (Optional) A list of scopes.
  - `registration` - (Optional) The registration configuration.
    - `client_id` - (Optional) The Client ID.
    - `client_secret_setting_name` - (Optional) The app setting name containing the client secret.
- `google` - (Optional) The Google provider configuration.
  - `enabled` - (Optional) Whether the provider is enabled.
  - `login` - (Optional) The login configuration.
    - `scopes` - (Optional) A list of scopes.
  - `registration` - (Optional) The registration configuration.
    - `client_id` - (Optional) The Client ID.
    - `client_secret_setting_name` - (Optional) The app setting name containing the client secret.
  - `validation` - (Optional) The validation configuration.
    - `allowed_audiences` - (Optional) A list of allowed audiences.
- `legacy_microsoft_account` - (Optional) The legacy Microsoft Account provider configuration.
  - `enabled` - (Optional) Whether the provider is enabled.
  - `login` - (Optional) The login configuration.
    - `scopes` - (Optional) A list of scopes.
  - `registration` - (Optional) The registration configuration.
    - `client_id` - (Optional) The Client ID.
    - `client_secret_setting_name` - (Optional) The app setting name containing the client secret.
  - `validation` - (Optional) The validation configuration.
    - `allowed_audiences` - (Optional) A list of allowed audiences.
- `twitter` - (Optional) The Twitter provider configuration.
  - `enabled` - (Optional) Whether the provider is enabled.
  - `registration` - (Optional) The registration configuration.
    - `consumer_key` - (Optional) The consumer key.
    - `consumer_secret_setting_name` - (Optional) The app setting name containing the consumer secret.
DESCRIPTION
}

variable "login" {
  type = object({
    allowed_external_redirect_urls = optional(list(string))
    cookie_expiration = optional(object({
      convention         = optional(string, "FixedTime")
      time_to_expiration = optional(string, "08:00:00")
    }))
    nonce = optional(object({
      nonce_expiration_interval = optional(string, "00:05:00")
      validate_nonce            = optional(bool, true)
    }))
    preserve_url_fragments_for_logins = optional(bool, false)
    routes = optional(object({
      logout_endpoint = optional(string)
    }))
    token_store = optional(object({
      azure_blob_storage = optional(object({
        sas_url_setting_name = optional(string)
      }))
      enabled = optional(bool, false)
      file_system = optional(object({
        directory = optional(string)
      }))
      token_refresh_extension_hours = optional(number, 72)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Login configuration for auth settings V2. Mirrors the API structure of `login`.

- `allowed_external_redirect_urls` - (Optional) A list of allowed external redirect URLs.
- `cookie_expiration` - (Optional) The cookie expiration configuration.
  - `convention` - (Optional) The cookie expiration convention. Defaults to `FixedTime`.
  - `time_to_expiration` - (Optional) The time after request when the session cookie should expire. Defaults to `08:00:00`.
- `nonce` - (Optional) The nonce configuration.
  - `nonce_expiration_interval` - (Optional) The time after request when the nonce should expire. Defaults to `00:05:00`.
  - `validate_nonce` - (Optional) Should the nonce be validated? Defaults to `true`.
- `preserve_url_fragments_for_logins` - (Optional) Should URL fragments be preserved for logins? Defaults to `false`.
- `routes` - (Optional) The login routes configuration.
  - `logout_endpoint` - (Optional) The logout endpoint.
- `token_store` - (Optional) The token store configuration.
  - `azure_blob_storage` - (Optional) The Azure Blob Storage token store configuration.
    - `sas_url_setting_name` - (Optional) The app setting name containing the SAS URL.
  - `enabled` - (Optional) Should the token store be enabled? Defaults to `false`.
  - `file_system` - (Optional) The file system token store configuration.
    - `directory` - (Optional) The directory for token storage.
  - `token_refresh_extension_hours` - (Optional) Hours after session token expiry for refresh. Defaults to `72`.
DESCRIPTION
}

variable "redirect_to_provider" {
  type        = string
  default     = null
  description = "The default authentication provider to use when multiple providers are configured."
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

variable "retry" {
  type = object({
    error_message_regex = list(string)
    interval_seconds    = optional(number, 10)
    max_retries         = optional(number, 3)
  })
  default = {
    error_message_regex = ["Cannot modify this site because another operation is in progress"]
  }
  description = "Retry configuration for azapi resources."
}

variable "runtime_version" {
  type        = string
  default     = "~1"
  description = "The runtime version of the auth module. Defaults to `~1`."
}

variable "unauthenticated_client_action" {
  type        = string
  default     = "RedirectToLoginPage"
  description = "The action for unauthenticated requests. Defaults to `RedirectToLoginPage`."
}
