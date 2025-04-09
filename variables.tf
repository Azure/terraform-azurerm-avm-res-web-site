# Required Inputs
variable "kind" {
  type        = string
  description = "The type of App Service to deploy. Possible values are `functionapp`, `webapp` and `logicapp`."

  validation {
    error_message = "The value must be on of: `functionapp`, `webapp` or `logicapp`"
    condition     = contains(["functionapp", "webapp", "logicapp"], var.kind)
  }
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name which should be used for the Function App."
}

variable "os_type" {
  type        = string
  description = "The operating system that should be the same type of the App Service Plan to deploy the App Service in."

  validation {
    error_message = "The value must be on of: `Linux` or `Windows`"
    condition     = contains(["Linux", "Windows"], var.os_type)
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where the App Service will be deployed."
}

variable "service_plan_resource_id" {
  type        = string
  description = "The resource ID of the App Service Plan to deploy the App Service in in."
}

variable "all_child_resources_inherit_lock" {
  type        = bool
  default     = true
  description = "Should the Function App inherit the lock from the parent resource? Defaults to `true`."
}

variable "all_child_resources_inherit_tags" {
  type        = bool
  default     = true
  description = "Should the Function App inherit tags from the parent resource? Defaults to `true`."
}

# Optional Inputs
variable "app_settings" {
  type = map(string)
  default = {

  }
  description = <<DESCRIPTION
  A map of key-value pairs for [App Settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) and custom values to assign to the Function App.

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
  ```
  DESCRIPTION
}

variable "application_insights" {
  type = object({
    application_type                      = optional(string, "web")
    inherit_tags                          = optional(bool, false)
    location                              = optional(string)
    name                                  = optional(string)
    resource_group_name                   = optional(string)
    tags                                  = optional(map(any), null)
    workspace_resource_id                 = optional(string)
    daily_data_cap_in_gb                  = optional(number)
    daily_data_cap_notifications_disabled = optional(bool)
    retention_in_days                     = optional(number, 90)
    sampling_percentage                   = optional(number, 100)
    disable_ip_masking                    = optional(bool, false)
    local_authentication_disabled         = optional(bool, false)
    internet_ingestion_enabled            = optional(bool, true)
    internet_query_enabled                = optional(bool, true)
    force_customer_storage_for_profiler   = optional(bool, false)
  })
  default = {

  }
  description = <<DESCRIPTION

  The Application Insights settings to assign to the Function App.

  -`application_type`: The type of Application Insights to create. Valid values are `ios`, `java`, `MobileCenter`, `Node.JS`, `other`, `phone`, `store`, and `web`. Defaults to `web`.
  -`inherit_tags`: Should the Application Insights inherit tags from the parent resource? Defaults to `false`.
  -`location`: The location of the Application Insights.
  -`name`: The name of the Application Insights.
  -`resource_group_name`: The name of the Resource Group where the Application Insights will be deployed.
  -`tags`: A map of tags to assign to the Application Insights.
  -`workspace_resource_id`: The resource ID of the Log Analytics Workspace to use for the Application Insights.
  -`daily_data_cap_in_gb`: The daily data cap in GB for the Application Insights.
  -`daily_data_cap_notifications_disabled`: Should the daily data cap notifications be disabled for the Application Insights?
  -`retention_in_days`: The retention period in days for the Application Insights. Defaults to `90`.
  -`sampling_percentage`: The sampling percentage for the Application Insights. Defaults to `100`.
  -`disable_ip_masking`: Should the IP masking be disabled for the Application Insights? Defaults to `false`.
  -`local_authentication_disabled`: Should the local authentication be disabled for the Application Insights? Defaults to `false`.
  -`internet_ingestion_enabled`: Should the internet ingestion be enabled for the Application Insights? Defaults to `true`.
  -`internet_query_enabled`: Should the internet query be enabled for the Application Insights? Defaults to `true`.
  -`force_customer_storage_for_profiler`: Should the customer storage be forced for the profiler for the Application Insights? Defaults to `false`.

  ```terraform
  application_insights = {
    name                  = module.naming.application_insights.name_unique
    resource_group_name   = module.avm_res_resources_resourcegroup.name
    location              = module.avm_res_resources_resourcegroup.resource.location
    application_type      = "web"
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    tags = {
      environment = "dev-tf"
    }
  }
  ```

  DESCRIPTION
}

variable "auth_settings" {
  type = map(object({
    additional_login_parameters    = optional(map(string))
    allowed_external_redirect_urls = optional(list(string))
    default_provider               = optional(string)
    enabled                        = optional(bool, false)
    issuer                         = optional(string)
    runtime_version                = optional(string)
    token_refresh_extension_hours  = optional(number, 72)
    token_store_enabled            = optional(bool, false)
    unauthenticated_client_action  = optional(string)
    active_directory = optional(map(object({
      client_id                  = optional(string)
      allowed_audiences          = optional(list(string))
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
    })), {})
    facebook = optional(map(object({
      app_id                  = optional(string)
      app_secret              = optional(string)
      app_secret_setting_name = optional(string)
      oauth_scopes            = optional(list(string))
    })), {})
    github = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })), {})
    google = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })), {})
    microsoft = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })), {})
    twitter = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret              = optional(string)
      consumer_secret_setting_name = optional(string)
    })), {})
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of authentication settings to assign to the Function App.
 - `additional_login_parameters` - (Optional) Specifies a map of login Parameters to send to the OpenID Connect authorization endpoint when a user logs in.
 - `allowed_external_redirect_urls` - (Optional) Specifies a list of External URLs that can be redirected to as part of logging in or logging out of the Linux Web App.
 - `default_provider` - (Optional) The default authentication provider to use when multiple providers are configured. Possible values include: `AzureActiveDirectory`, `Facebook`, `Google`, `MicrosoftAccount`, `Twitter`, `Github`
 - `enabled` - (Required) Should the Authentication / Authorization feature be enabled for the Linux Web App?
 - `issuer` - (Optional) The OpenID Connect Issuer URI that represents the entity which issues access tokens for this Linux Web App.
 - `runtime_version` - (Optional) The RuntimeVersion of the Authentication / Authorization feature in use for the Linux Web App.
 - `token_refresh_extension_hours` - (Optional) The number of hours after session token expiration that a session token can be used to call the token refresh API. Defaults to `72` hours.
 - `token_store_enabled` - (Optional) Should the Linux Web App durably store platform-specific security tokens that are obtained during login flows? Defaults to `false`.
 - `unauthenticated_client_action` - (Optional) The action to take when an unauthenticated client attempts to access the app. Possible values include: `RedirectToLoginPage`, `AllowAnonymous`.

 ---
 `active_directory` block supports the following:
 - `allowed_audiences` - (Optional) Specifies a list of Allowed audience values to consider when validating JWTs issued by Azure Active Directory.
 - `client_id` - (Required) The ID of the Client to use to authenticate with Azure Active Directory.
 - `client_secret` - (Optional) The Client Secret for the Client ID. Cannot be used with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The App Setting name that contains the client secret of the Client. Cannot be used with `client_secret`.

 ---
 `facebook` block supports the following:
 - `app_id` - (Required) The App ID of the Facebook app used for login.
 - `app_secret` - (Optional) The App Secret of the Facebook app used for Facebook login. Cannot be specified with `app_secret_setting_name`.
 - `app_secret_setting_name` - (Optional) The app setting name that contains the `app_secret` value used for Facebook login. Cannot be specified with `app_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes to be requested as part of Facebook login authentication.

 ---
 `github` block supports the following:
 - `client_id` - (Required) The ID of the GitHub app used for login.
 - `client_secret` - (Optional) The Client Secret of the GitHub app used for GitHub login. Cannot be specified with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The app setting name that contains the `client_secret` value used for GitHub login. Cannot be specified with `client_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes that will be requested as part of GitHub login authentication.

 ---
 `google` block supports the following:
 - `client_id` - (Required) The OpenID Connect Client ID for the Google web application.
 - `client_secret` - (Optional) The client secret associated with the Google web application. Cannot be specified with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The app setting name that contains the `client_secret` value used for Google login. Cannot be specified with `client_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes that will be requested as part of Google Sign-In authentication. If not specified, `openid`, `profile`, and `email` are used as default scopes.

 ---
 `microsoft` block supports the following:
 - `client_id` - (Required) The OAuth 2.0 client ID that was created for the app used for authentication.
 - `client_secret` - (Optional) The OAuth 2.0 client secret that was created for the app used for authentication. Cannot be specified with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The app setting name containing the OAuth 2.0 client secret that was created for the app used for authentication. Cannot be specified with `client_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes that will be requested as part of Microsoft Account authentication. If not specified, `wl.basic` is used as the default scope.

 ---
 `twitter` block supports the following:
 - `consumer_key` - (Required) The OAuth 1.0a consumer key of the Twitter application used for sign-in.
 - `consumer_secret` - (Optional) The OAuth 1.0a consumer secret of the Twitter application used for sign-in. Cannot be specified with `consumer_secret_setting_name`.
 - `consumer_secret_setting_name` - (Optional) The app setting name that contains the OAuth 1.0a consumer secret of the Twitter application used for sign-in. Cannot be specified with `consumer_secret`.

  ```terraform
  auth_settings = {
    example = {
      enabled = true
      active_directory = {
        client_id                  = "00000000-0000-0000-0000-000000000000"
        allowed_audiences          = ["00000000-0000-0000-0000-000000000000"]
        client_secret              = "00000000-0000-0000-0000-000000000000"
        client_secret_setting_name = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  ```
  DESCRIPTION
}

variable "auth_settings_v2" {
  type = map(object({
    auth_enabled                            = optional(bool, false)
    config_file_path                        = optional(string)
    default_provider                        = optional(string)
    excluded_paths                          = optional(list(string))
    forward_proxy_convention                = optional(string, "NoProxy")
    forward_proxy_custom_host_header_name   = optional(string)
    forward_proxy_custom_scheme_header_name = optional(string)
    http_route_api_prefix                   = optional(string, "/.auth")
    require_authentication                  = optional(bool, false)
    require_https                           = optional(bool, true)
    runtime_version                         = optional(string, "~1")
    unauthenticated_action                  = optional(string, "RedirectToLoginPage")
    active_directory_v2 = optional(map(object({
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
    })), {})
    apple_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })), {})
    azure_static_web_app_v2 = optional(map(object({
      client_id = optional(string)
    })), {})
    custom_oidc_v2 = optional(map(object({
      authorisation_endpoint        = optional(string)
      certification_uri             = optional(string)
      client_credential_method      = optional(string)
      client_id                     = optional(string)
      client_secret_setting_name    = optional(string)
      issuer_endpoint               = optional(string)
      name                          = optional(string)
      name_claim_type               = optional(string)
      openid_configuration_endpoint = optional(string)
      scopes                        = optional(list(string))
      token_endpoint                = optional(string)
    })), {})
    facebook_v2 = optional(map(object({
      app_id                  = optional(string)
      app_secret_setting_name = optional(string)
      graph_api_version       = optional(string)
      login_scopes            = optional(list(string))
    })), {})
    github_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })), {})
    google_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })), {})
    login = optional(map(object({
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration_convention      = optional(string, "FixedTime")
      cookie_expiration_time            = optional(string, "00:00:00")
      logout_endpoint                   = optional(string)
      nonce_expiration_time             = optional(string, "00:05:00")
      preserve_url_fragments_for_logins = optional(bool, false)
      token_refresh_extension_time      = optional(number, 72)
      token_store_enabled               = optional(bool, false)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      validate_nonce                    = optional(bool, true)
      })),
      {
        login = {

        }
    })
    microsoft_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })), {})
    twitter_v2 = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret_setting_name = optional(string)
    })), {})

  }))
  default = {

  }
  description = <<DESCRIPTION
A map of authentication settings (V2) to assign to the Function App.

- `auth_enabled` - (Optional) Should the AuthV2 Settings be enabled. Defaults to `false`.
- `config_file_path` - (Optional) The path to the App Auth settings.
- `default_provider` - (Optional) The Default Authentication Provider to use when the `unauthenticated_action` is set to `RedirectToLoginPage`. Possible values include: `apple`, `azureactivedirectory`, `facebook`, `github`, `google`, `twitter` and the `name` of your `custom_oidc_v2` provider.
- `excluded_paths` - (Optional) The paths which should be excluded from the `unauthenticated_action` when it is set to `RedirectToLoginPage`.
- `forward_proxy_convention` - (Optional) The convention used to determine the url of the request made. Possible values include `NoProxy`, `Standard`, `Custom`. Defaults to `NoProxy`.
- `forward_proxy_custom_host_header_name` - (Optional) The name of the custom header containing the host of the request.
- `forward_proxy_custom_scheme_header_name` - (Optional) The name of the custom header containing the scheme of the request.
- `http_route_api_prefix` - (Optional) The prefix that should precede all the authentication and authorisation paths. Defaults to `/.auth`.
- `require_authentication` - (Optional) Should the authentication flow be used for all requests.
- `require_https` - (Optional) Should HTTPS be required on connections? Defaults to `true`.
- `runtime_version` - (Optional) The Runtime Version of the Authentication and Authorisation feature of this App. Defaults to `~1`.
- `unauthenticated_action` - (Optional) The action to take for requests made without authentication. Possible values include `RedirectToLoginPage`, `AllowAnonymous`, `Return401`, and `Return403`. Defaults to `RedirectToLoginPage`.

---
`active_directory_v2` block supports the following:
- `allowed_applications` - (Optional) The list of allowed Applications for the Default Authorisation Policy.
- `allowed_audiences` - (Optional) Specifies a list of Allowed audience values to consider when validating JWTs issued by Azure Active Directory.
- `allowed_groups` - (Optional) The list of allowed Group Names for the Default Authorisation Policy.
- `allowed_identities` - (Optional) The list of allowed Identities for the Default Authorisation Policy.
- `client_id` - (Required) The ID of the Client to use to authenticate with Azure Active Directory.
- `client_secret_certificate_thumbprint` - (Optional) The thumbprint of the certificate used for signing purposes.
- `client_secret_setting_name` - (Optional) The App Setting name that contains the client secret of the Client.
- `jwt_allowed_client_applications` - (Optional) A list of Allowed Client Applications in the JWT Claim.
- `jwt_allowed_groups` - (Optional) A list of Allowed Groups in the JWT Claim.
- `login_parameters` - (Optional) A map of key-value pairs to send to the Authorisation Endpoint when a user logs in.
- `tenant_auth_endpoint` - (Required) The Azure Tenant Endpoint for the Authenticating Tenant. e.g. `https://login.microsoftonline.com/v2.0/{tenant-guid}/`
- `www_authentication_disabled` - (Optional) Should the www-authenticate provider should be omitted from the request? Defaults to `false`.

---
`apple_v2` block supports the following:
- `client_id` - (Required) The OpenID Connect Client ID for the Apple web application.
- `client_secret_setting_name` - (Required) The app setting name that contains the `client_secret` value used for Apple Login.

---
`azure_static_web_app_v2` block supports the following:
- `client_id` - (Required) The ID of the Client to use to authenticate with Azure Static Web App Authentication.

---
`custom_oidc_v2` block supports the following:
- `client_id` - (Required) The ID of the Client to use to authenticate with the Custom OIDC.
- `name` - (Required) The name of the Custom OIDC Authentication Provider.
- `name_claim_type` - (Optional) The name of the claim that contains the users name.
- `openid_configuration_endpoint` - (Required) The app setting name that contains the `client_secret` value used for the Custom OIDC Login.
- `scopes` - (Optional) The list of the scopes that should be requested while authenticating.

---
`facebook_v2` block supports the following:
- `app_id` - (Required) The App ID of the Facebook app used for login.
- `app_secret_setting_name` - (Required) The app setting name that contains the `app_secret` value used for Facebook Login.
- `graph_api_version` - (Optional) The version of the Facebook API to be used while logging in.
- `login_scopes` - (Optional) The list of scopes that should be requested as part of Facebook Login authentication.

---
`github_v2` block supports the following:
- `client_id` - (Required) The ID of the GitHub app used for login..
- `client_secret_setting_name` - (Required) The app setting name that contains the `client_secret` value used for GitHub Login.
- `login_scopes` - (Optional) The list of OAuth 2.0 scopes that should be requested as part of GitHub Login authentication.

---
`google_v2` block supports the following:
- `allowed_audiences` - (Optional) Specifies a list of Allowed Audiences that should be requested as part of Google Sign-In authentication.
- `client_id` - (Required) The OpenID Connect Client ID for the Google web application.
- `client_secret_setting_name` - (Required) The app setting name that contains the `client_secret` value used for Google Login.
- `login_scopes` - (Optional) The list of OAuth 2.0 scopes that should be requested as part of Google Sign-In authentication.

---
`login` block supports the following:
- `allowed_external_redirect_urls` - (Optional) External URLs that can be redirected to as part of logging in or logging out of the app. This is an advanced setting typically only needed by Windows Store application backends.
- `cookie_expiration_convention` - (Optional) The method by which cookies expire. Possible values include: `FixedTime`, and `IdentityProviderDerived`. Defaults to `FixedTime`.
- `cookie_expiration_time` - (Optional) The time after the request is made when the session cookie should expire. Defaults to `08:00:00`.
- `logout_endpoint` - (Optional) The endpoint to which logout requests should be made.
- `nonce_expiration_time` - (Optional) The time after the request is made when the nonce should expire. Defaults to `00:05:00`.
- `preserve_url_fragments_for_logins` - (Optional) Should the fragments from the request be preserved after the login request is made. Defaults to `false`.
- `token_refresh_extension_time` - (Optional) The number of hours after session token expiration that a session token can be used to call the token refresh API. Defaults to `72` hours.
- `token_store_enabled` - (Optional) Should the Token Store configuration Enabled. Defaults to `false`
- `token_store_path` - (Optional) The directory path in the App Filesystem in which the tokens will be stored.
- `token_store_sas_setting_name` - (Optional) The name of the app setting which contains the SAS URL of the blob storage containing the tokens.
- `validate_nonce` - (Optional) Should the nonce be validated while completing the login flow. Defaults to `true`.

---
`microsoft_v2` block supports the following:
- `allowed_audiences` - (Optional) Specifies a list of Allowed Audiences that will be requested as part of Microsoft Sign-In authentication.
- `client_id` - (Required) The OAuth 2.0 client ID that was created for the app used for authentication.
- `client_secret_setting_name` - (Required) The app setting name containing the OAuth 2.0 client secret that was created for the app used for authentication.
- `login_scopes` - (Optional) The list of Login scopes that should be requested as part of Microsoft Account authentication.

---
`twitter_v2` block supports the following:
- `consumer_key` - (Required) The OAuth 1.0a consumer key of the Twitter application used for sign-in.
- `consumer_secret_setting_name` - (Required) The app setting name that contains the OAuth 1.0a consumer secret of the Twitter application used for sign-in.

```terraform
  auth_settings_v2 = {
    setting1 = {
      auth_enabled     = true
      default_provider = "AzureActiveDirectory"
      active_directory_v2 = {
        aad1 = {
          client_id            = "<client-id>"
          tenant_auth_endpoint = "https://login.microsoftonline.com/{tenant-guid}/v2.0/"
        }
      }
      login = {
        login1 = {
          token_store_enabled = true
        }
      }
    }
  }
  ```
  DESCRIPTION
}

variable "auto_heal_setting" {
  type = map(object({
    action = optional(object({
      action_type = string
      custom_action = optional(object({
        executable = string
        parameters = optional(string)
      }))
      minimum_process_execution_time = optional(string, "00:00:00")
    }))
    trigger = optional(object({
      private_memory_kb = optional(number)
      requests = optional(map(object({
        count    = number
        interval = string
      })), {})
      slow_request = optional(map(object({
        count      = number
        interval   = string
        time_taken = string
        path       = optional(string)
      })), {})
      slow_request_with_path = optional(map(object({
        count      = number
        interval   = string
        time_taken = string
        path       = optional(string)
      })), {})
      status_code = optional(map(object({
        count             = number
        interval          = string
        status_code_range = string
        path              = optional(string)
        sub_status        = optional(number)
        win32_status_code = optional(number)
      })), {})
    }))
  }))
  default = {

  }
  description = <<DESCRIPTION

  Configures the Auto Heal settings for the Function App. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `action` - (Optional) The action to take when the trigger is activated.
    - `action_type` - (Required) The type of action to take. Possible values include: `CustomAction`, `Recycle`, `LogEvent`, `HttpRequst`.
    - `custom_action` - (Optional) The custom action to take when the trigger is activated.
      - `executable` - (Required) The executable to run when the trigger is activated.
      - `parameters` - (Optional) The parameters to pass to the executable.
    - `minimum_process_execution_time` - (Optional) The minimum process execution time before the action is taken. Defaults to `00:00:00`.
  - `trigger` - (Optional) The trigger to activate the action.
    - `private_memory_kb` - (Optional) The private memory in kilobytes to trigger the action.
    - `requests` - (Optional) The requests trigger to activate the action.
      - `count` - (Required) The number of requests to trigger the action.
      - `interval` - (Required) The interval to trigger the action.
    - `slow_request` - (Optional) The slow request trigger to activate the action.
      - `count` - (Required) The number of slow requests to trigger the action.
      - `interval` - (Required) The interval to trigger the action.
      - `time_taken` - (Required) The time taken to trigger the action.
      - `path` - (Optional) The path to trigger the action.
      > NOTE: The `path` property in the `slow_request` block is deprecated and will be removed in 4.0 of provider. Please use `slow_request_with_path` to set a slow request trigger with `path` specified.
    - `status_code` - (Optional) The status code trigger to activate the action.
      - `count` - (Required) The number of status codes to trigger the action.
      - `interval` - (Required) The interval to trigger the action.
      - `status_code_range` - (Required) The status code range to trigger the action.
      - `path` - (Optional) The path to trigger the action.
      - `sub_status` - (Optional) The sub status to trigger the action.
      - `win32_status_code` - (Optional) The Win32 status code to trigger the action.

  ```terraform
  auto_heal_setting = {
    setting_1 = {
      action = {
        action_type                    = "Recycle"
        minimum_process_execution_time = "00:01:00"
      }
      trigger = {
        requests = {
          count    = 100
          interval = "00:00:30"
        }
        status_code = {
          status_5000 = {
            count             = 5000
            interval          = "00:05:00"
            path              = "/HealthCheck"
            status_code_range = 500
            sub_status        = 0
          }
          status_6000 = {
            count             = 6000
            interval          = "00:05:00"
            path              = "/Get"
            status_code_range = 500
            sub_status        = 0
          }
        }
      }
    }
  }
  ```

  DESCRIPTION
  nullable    = false
}

variable "backup" {
  type = map(object({
    enabled             = optional(bool, true)
    name                = optional(string)
    storage_account_url = optional(string)
    schedule = optional(map(object({
      frequency_interval       = optional(number)
      frequency_unit           = optional(string)
      keep_at_least_one_backup = optional(bool)
      retention_period_days    = optional(number)
      start_time               = optional(string)
    })))
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of backup settings to assign to the Function App.
  - `name` - (Optional) The name of the backup. One will be generated if not set.
  - `schedule` - (Optional) A map of backup schedule settings.
    - `frequency_interval` - (Optional) The frequency interval of the backup.
    - `frequency_unit` - (Optional) The frequency unit of the backup.
    - `keep_at_least_one_backup` - (Optional) Should at least one backup be kept?.
    - `retention_period_in_days` - (Optional) The retention period in days of the backup.
    - `start_time` - (Optional) The start time of the backup.
  - `storage_account_url` - (Optional) The URL of the Storage Account to store the backup in.
  - `enabled` - (Optional) Is the backup enabled? Defaults to `true`.

  ```terraform
  backup = {
    example = {
      name               = "example"
      schedule = {
        frequency_interval       = 1
        frequency_unit           = "Day"
        keep_at_least_one_backup = true
        retention_period_in_days = 7
        start_time               = "2020-01-01T00:00:00Z"
      }
      storage_account_url = "https://example.blob.core.windows.net/example"
      enabled             = true
    }
  }
  ```
  DESCRIPTION
}

variable "builtin_logging_enabled" {
  type        = bool
  default     = true
  description = "Should builtin logging be enabled for the Function App?"
}

variable "bundle_version" {
  type        = string
  default     = "[1.*, 2.0.0)"
  description = "The version of the extension bundle to use. Defaults to `[1.*, 2.0.0)`. (Logic App)"
}

variable "client_affinity_enabled" {
  type        = bool
  default     = false
  description = "Should client affinity be enabled for the Function App?"
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Should client certificate be enabled for the Function App?"
}

variable "client_certificate_exclusion_paths" {
  type        = string
  default     = null
  description = "The client certificate exclusion paths for the Function App."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "The client certificate mode for the Function App."
}

variable "connection_strings" {
  type = map(object({
    name  = optional(string)
    type  = optional(string)
    value = optional(string)
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of connection strings to assign to the Function App.
  - `name` - (Optional) The name of the connection string.
  - `type` - (Optional) The type of the connection string.
  - `value` - (Optional) The value of the connection string.
  ```terraform
  connection_strings = {
    example = {
      name  = "example"
      type  = "example"
      value = "example"
    }
  }
  ```
  DESCRIPTION
}

variable "content_share_force_disabled" {
  type        = bool
  default     = false
  description = "Should content share be force disabled for the Function App?"
}

variable "custom_domains" {
  type = map(object({
    slot_as_target               = optional(bool, false)
    app_service_slot_key         = optional(string)
    create_certificate           = optional(bool, false)
    certificate_name             = optional(string)
    certificate_location         = optional(string)
    pfx_blob                     = optional(string)
    pfx_password                 = optional(string)
    hostname                     = optional(string)
    app_service_name             = optional(string)
    app_service_plan_resource_id = optional(string)
    key_vault_secret_id          = optional(string)
    key_vault_id                 = optional(string)
    zone_resource_group_name     = optional(string)
    resource_group_name          = optional(string)
    ssl_state                    = optional(string)
    inherit_tags                 = optional(bool, true)
    tags                         = optional(map(any), {})
    thumbprint_key               = optional(string)
    thumbprint_value             = optional(string)
    ttl                          = optional(number, 300)
    validation_type              = optional(string, "cname-delegation")
    create_cname_records         = optional(bool, false)
    cname_name                   = optional(string)
    cname_zone_name              = optional(string)
    cname_record                 = optional(string)
    cname_target_resource_id     = optional(string)
    create_txt_records           = optional(bool, false)
    txt_name                     = optional(string)
    txt_zone_name                = optional(string)
    txt_records                  = optional(map(object({ value = string })))
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of custom domains to assign to the Function App.
  - `slot_as_target` - (optional) Will this custom domain configuration be used for a App Service slot? Defaults to `false`.
  - `app_service_slot_key` - (Optional) The key of the App Service Slot to use as the target for the custom domain.
  - `app_service_plan_resource_id` - (Optional) The resource ID of the App Service Plan to use for the custom domain.
  - `key_vault_secret_id` - (Optional) The ID of the Key Vault Secret to use for the custom domain.
  - `create_certificate` - (Optional) Should a certificate be created for the custom domain? Defaults to `false`.
  - `create_txt_records` - (Optional) Should TXT records be created for the custom domain? Defaults to `false`.
  - `create_cname_records` - (Optional) Should CNAME records be created for the custom domain? Defaults to `false`.

  ```terraform
  custom_domains = {
    # Allows for the configuration of custom domains for the Function App
    # If not already set, the module allows for the creation of TXT and CNAME records

    custom_domain_1 = {

      zone_resource_group_name = "<zone_resource_group_name>"

      create_txt_records = true
      txt_name           = "asuid.<module.naming.function_app.name_unique>"
      txt_zone_name      = "<zone_name>"
      txt_records = {
        record = {
          value = "" # Leave empty as module will reference Function App ID after Function App creation
        }
      }

      create_cname_records = true
      cname_name           = "<module.naming.function_app.name_unique>"
      cname_zone_name      = "<zone_name>"
      cname_record         = "<module.naming.function_app.name_unique>-custom-domain.azurewebsites.net"

      create_certificate   = true
      certificate_name     = "<module.naming.function_app.name_unique>-<data.azurerm_key_vault_secret.stored_certificate.name>"
      certificate_location = azurerm_resource_group.example.location
      pfx_blob             = data.azurerm_key_vault_secret.stored_certificate.value

      app_service_name    = "<module.naming.function_app.name_unique>-custom-domain"
      hostname            = "<module.naming.function_app.name_unique>.<root_domain>"
      resource_group_name = azurerm_resource_group.example.name
      ssl_state           = "SniEnabled"
      thumbprint_key      = "custom_domain_1" # Currently the key of the custom domain
    }

  }
  ```
  DESCRIPTION
}

variable "daily_memory_time_quota" {
  type        = number
  default     = 0
  description = "(Optional) The amount of memory in gigabyte-seconds that your application is allowed to consume per day. Setting this value only affects Function Apps under the consumption plan. Defaults to `0`."
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
  - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
  - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
  - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`. Will resolve to `null` as Function App / web App does not support Destination Table.
  - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
  - `storage_account_resource_id` - (Optional) The resource ID of the Storage Account to send logs and metrics to.
  - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
  - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
  - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
  DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_application_insights" {
  type        = bool
  default     = true
  description = "Should Application Insights be enabled for the Function App?"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
  This variable controls whether or not telemetry is enabled for the module.
  For more information see <https://aka.ms/avm/telemetryinfo>.
  If it is set to false, then no telemetry will be collected.
  DESCRIPTION
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Is the Function App enabled? Defaults to `true`."
}

variable "fc1_runtime_name" {
  type        = string
  default     = null
  description = "The Runtime of the Linux Function App. Possible values are `node`, `dotnet-isolated`, `powershell`, `python`, `java`."
}

variable "fc1_runtime_version" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  The Runtime version of the Linux Function App. The supported values are different depending on the runtime chosen with `runtime_name`:
  - `dotnet-isolated` supported values are: `8.0`, `9.0`
  - `node` supported values are: `20`
  - `python` supported values are: `3.10`, `3.11`
  - `java` supported values are: `11`, `17`
  - `powershell` supported values are: `7.4`
  DESCRIPTION
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  default     = true
  description = "Should basic authentication be enabled for FTP publish?"
}

variable "function_app_uses_fc1" {
  type        = bool
  default     = false
  description = "Should this Function App run on a Flex Consumption Plan?"
}

variable "functions_extension_version" {
  type        = string
  default     = "~4"
  description = "The version of the Azure Functions runtime to use. Defaults to `~4`."
}

variable "https_only" {
  type        = bool
  default     = false
  description = "Should the Function App only be accessible over HTTPS?"
}

variable "instance_memory_in_mb" {
  type        = number
  default     = 2048
  description = "The amount of memory to allocate for the instance(s)."

  validation {
    error_message = "The value must be on of: `2048 or `4096`"
    condition     = contains([2048, 4096], var.instance_memory_in_mb)
  }
}

variable "key_vault_reference_identity_id" {
  type        = string
  default     = null
  description = "The identity ID to use for Key Vault references."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)

  })
  default     = null
  description = "The lock level to apply. Possible values for `kind` are `None`, `CanNotDelete`, and `ReadOnly`."

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: `CanNotDelete`, or `ReadOnly`."
  }
}

variable "logic_app_runtime_version" {
  type        = string
  default     = "~4"
  description = " The runtime version associated with the Logic App. Defaults to ~4 (Logic App)"
}

variable "logs" {
  type = object({
    application_logs = optional(object({
      azure_blob_storage = optional(object({
        level             = string
        retention_in_days = number
        sas_url           = string
      }), null)
      file_system_level = string
    }), null)
    detailed_error_messages = optional(bool)
    failed_request_tracing  = optional(bool)
    http_logs = optional(object({
      azure_blob_storage_http = optional(object({
        retention_in_days = optional(number)
        sas_url           = string
      }), null)
      file_system = optional(object({
        retention_in_days = number
        retention_in_mb   = number
      }), null)
    }), null)
  })
  nullable    = true
  default     = null

  description = <<DESCRIPTION


  A map of logs to create on the Function App.

  DESCRIPTION

}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identities to be created for the resource."
  nullable    = false
}

variable "maximum_instance_count" {
  type        = number
  default     = null
  description = "The number of workers this function app can scale out to."
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating private endpoints if the principal creating the assignment is constrained by RBAC rules that filters on the PrincipalType attribute.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.
DESCRIPTION
  nullable    = false
}

variable "private_endpoints_inherit_lock" {
  type        = bool
  default     = true
  description = "Should the private endpoints inherit the lock from the parent resource? Defaults to `true`."
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Should the Function App be accessible from the public network? Defaults to `true`."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to `false`.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are `2.0`.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "site_config" {
  type = object({
    always_on             = optional(bool, true)
    linux_fx_version      = optional(string)
    api_definition_url    = optional(string)
    api_management_api_id = optional(string)
    app_command_line      = optional(string)
    # auto_heal_enabled                             = optional(bool)
    dotnet_framework_version                      = optional(string, "v4.0")
    auto_swap_slot_name                           = optional(string)
    app_scale_limit                               = optional(number)
    application_insights_connection_string        = optional(string)
    application_insights_key                      = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    default_documents                             = optional(list(string))
    elastic_instance_minimum                      = optional(number)
    ftps_state                                    = optional(string, "FtpsOnly")
    health_check_eviction_time_in_min             = optional(number)
    health_check_path                             = optional(string)
    http2_enabled                                 = optional(bool, false)
    ip_restriction_default_action                 = optional(string, "Allow")
    load_balancing_mode                           = optional(string, "LeastRequests")
    local_mysql_enabled                           = optional(bool, false)
    managed_pipeline_mode                         = optional(string, "Integrated")
    minimum_tls_version                           = optional(string, "1.3")
    pre_warmed_instance_count                     = optional(number)
    remote_debugging_enabled                      = optional(bool, false)
    remote_debugging_version                      = optional(string)
    runtime_scale_monitoring_enabled              = optional(bool)
    scm_type                                      = optional(string, "None")
    scm_ip_restriction_default_action             = optional(string, "Allow")
    scm_minimum_tls_version                       = optional(string, "1.2")
    scm_use_main_ip_restriction                   = optional(bool, false)
    use_32_bit_worker                             = optional(bool, false)
    vnet_route_all_enabled                        = optional(bool, false)
    websockets_enabled                            = optional(bool, false)
    worker_count                                  = optional(number)
    app_service_logs = optional(map(object({
      disk_quota_mb         = optional(number, 35)
      retention_period_days = optional(number)
    })), {})
    application_stack = optional(map(object({
      dotnet_core_version         = optional(string)
      dotnet_version              = optional(string)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
      python_version              = optional(string)
      go_version                  = optional(string)
      ruby_version                = optional(string)
      java_server                 = optional(string)
      java_server_version         = optional(string)
      php_version                 = optional(string)
      use_custom_runtime          = optional(bool)
      use_dotnet_isolated_runtime = optional(bool)
      docker = optional(list(object({
        image_name        = string
        image_tag         = string
        registry_password = optional(string)
        registry_url      = string
        registry_username = optional(string)
      })))
      current_stack                = optional(string)
      docker_image_name            = optional(string)
      docker_registry_url          = optional(string)
      docker_registry_username     = optional(string)
      docker_registry_password     = optional(string)
      docker_container_name        = optional(string)
      docker_container_tag         = optional(string)
      java_embedded_server_enabled = optional(bool)
      tomcat_version               = optional(bool)
    })), {})
    cors = optional(map(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool, false)
    })), {})
    ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {})
    scm_ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {})
    virtual_application = optional(map(object({
      physical_path   = optional(string, "site\\wwwroot")
      preload_enabled = optional(bool, false)
      virtual_directory = optional(map(object({
        physical_path = optional(string)
        virtual_path  = optional(string)
      })), {})
      virtual_path = optional(string, "/")
      })),
      {
        default = {
          physical_path   = "site\\wwwroot"
          preload_enabled = false
          virtual_path    = "/"
        }
    })
  })
  default     = {}
  description = <<DESCRIPTION
  An object that configures the Function App's `site_config` block.
 - `always_on` - (Optional) If this Linux Web App is Always On enabled. Defaults to `true`.
 - `auto_swap_slot_name` - (Optional) The name of the slot to swap with. (Logic App)
 - `api_definition_url` - (Optional) The URL of the API definition that describes this Linux Function App.
 - `api_management_api_id` - (Optional) The ID of the API Management API for this Linux Function App.
 - `app_command_line` - (Optional) The App command line to launch.
 - `app_scale_limit` - (Optional) The number of workers this function app can scale out to. Only applicable to apps on the Consumption and Premium plan.
 - `application_insights_connection_string` - (Optional) The Connection String for linking the Linux Function App to Application Insights.
 - `application_insights_key` - (Optional) The Instrumentation Key for connecting the Linux Function App to Application Insights.
 - `container_registry_managed_identity_client_id` - (Optional) The Client ID of the Managed Service Identity to use for connections to the Azure Container Registry.
 - `container_registry_use_managed_identity` - (Optional) Should connections for Azure Container Registry use Managed Identity.
 - `default_documents` - (Optional) Specifies a list of Default Documents for the Linux Web App.
 - `dotnet_framework_version` - (Optional) The version of the .NET Framework to use. Possible values are `v4.0` (including .NET Core 2.1 and 3.1), `v5.0`, `v6.0` and `v8.0`. Defaults to `v4.0`.
 - `elastic_instance_minimum` - (Optional) The number of minimum instances for this Linux Function App. Only affects apps on Elastic Premium plans.
 - `ftps_state` - (Optional) State of FTP / FTPS service for this function app. Possible values include: `AllAllowed`, `FtpsOnly` and `Disabled`. Defaults to `FtpsOnly`.
 - `health_check_eviction_time_in_min` - (Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between `2` and `10`. Only valid in conjunction with `health_check_path`.
 - `health_check_path` - (Optional) The path to be checked for this function app health.
 - `http2_enabled` - (Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to `false`.
 - `load_balancing_mode` - (Optional) The Site load balancing mode. Possible values include: `WeightedRoundRobin`, `LeastRequests`, `LeastResponseTime`, `WeightedTotalTraffic`, `RequestHash`, `PerSiteRoundRobin`. Defaults to `LeastRequests` if omitted.
 - `linux_fx_version` - (Optional) Linux App Framework and version for the App Service, e.g. `DOCKER|(golang:latest)`. Setting this value will also set the kind of application deployed to `functionapp,linux,container,workflowapp`. You must set `os_type` to `Linux` when this property is set.
 - `managed_pipeline_mode` - (Optional) Managed pipeline mode. Possible values include: `Integrated`, `Classic`. Defaults to `Integrated`.
 - `minimum_tls_version` - (Optional) The configures the minimum version of TLS required for SSL requests. Possible values include: `1.0`, `1.1`, `1.2`, and `1.3`. Defaults to `1.3`.
 - `pre_warmed_instance_count` - (Optional) The number of pre-warmed instances for this function app. Only affects apps on an Elastic Premium plan.
 - `remote_debugging_enabled` - (Optional) Should Remote Debugging be enabled. Defaults to `false`.
 - `remote_debugging_version` - (Optional) The Remote Debugging Version. Possible values include `VS2017`, `VS2019`, and `VS2022`.
 - `runtime_scale_monitoring_enabled` - (Optional) Should Scale Monitoring of the Functions Runtime be enabled?
 - `scm_minimum_tls_version` - (Optional) Configures the minimum version of TLS required for SSL requests to the SCM site Possible values include: `1.0`, `1.1`, and `1.2`. Defaults to `1.2`.
 - `scm_use_main_ip_restriction` - (Optional) Should the Linux Function App `ip_restriction` configuration be used for the SCM also.
 - `scm_type` - (Optional) The type of SCM to use. Possible values include: `None`, `LocalGit`, `GitHub`, `BitbucketGit`, `BitBucketHg`, `CodePlexHg`, `CodePlexGit`, `Dropbox`, `Tfs`, `VSO`, `VSTSRM`, `ExternalGit`, `ExternalHg` and `OneDrive`. Defaults to `None`.
 - `use_32_bit_worker` - (Optional) Should the Linux Web App use a 32-bit worker process. Defaults to `false`.
 - `vnet_route_all_enabled` - (Optional) Should all outbound traffic to have NAT Gateways, Network Security Groups and User Defined Routes applied? Defaults to `false`.
 - `websockets_enabled` - (Optional) Should Web Sockets be enabled. Defaults to `false`.
 - `worker_count` - (Optional) The number of Workers for this Linux Function App.

 ---
 `app_service_logs` block supports the following:
 - `disk_quota_mb` - (Optional) The amount of disk space to use for logs. Valid values are between `25` and `100`. Defaults to `35`.
 - `retention_period_days` - (Optional) The retention period for logs in days. Valid values are between `0` and `99999`.(never delete).

 ---
 `application_stack` block supports the following:
 - `dotnet_core_version` - (Optional) The version of .NET Core to use. Possible values include `v4.0`.
 - `dotnet_version` - (Optional) The version of .NET to use. Possible values include `3.1`, `6.0`, `7.0` and `8.0`.
 - `java_version` - (Optional) The Version of Java to use. Supported versions include `8`, `11` & `17`.
 - `node_version` - (Optional) The version of Node to run. Possible values include `12`, `14`, `16` and `18`.
 - `powershell_core_version` - (Optional) The version of PowerShell Core to run. Possible values are `7`, and `7.2`.
 - `python_version` - (Optional) The version of Python to run. Possible values are `3.12`, `3.11`, `3.10`, `3.9`, `3.8` and `3.7`.
 - `go_version` - (Optional) The version of Go to use. Possible values are `1.18`, and `1.19`.
 - `ruby_version` - (Optional) The version of Ruby to use. Possible values are `2.6`, and `2.7`.
 - `java_server` - (Optional) The Java server type. Possible values are `JAVA`, `TOMCAT`, and `JBOSSEAP`.
 - `java_server_version` - (Optional) The version of the Java server to use.
 - `php_version` - (Optional) The version of PHP to use. Possible values are `7.4`, `8.0`, `8.1`, and `8.2`.
 - `use_custom_runtime` - (Optional) Should the Linux Function App use a custom runtime?
 - `use_dotnet_isolated_runtime` - (Optional) Should the DotNet process use an isolated runtime. Defaults to `false`.

 ---
 `docker` block supports the following:
 - `image_name` - (Required) The name of the Docker image to use.
 - `image_tag` - (Required) The image tag of the image to use.
 - `registry_password` - (Optional) The password for the account to use to connect to the registry.
 - `registry_url` - (Required) The URL of the docker registry.
 - `registry_username` - (Optional) The username to use for connections to the registry.

 ---
 `cors` block supports the following:
 - `allowed_origins` - (Optional) Specifies a list of origins that should be allowed to make cross-origin calls.
 - `support_credentials` - (Optional) Are credentials allowed in CORS requests? Defaults to `false`.

 ---
 `ip_restriction` block supports the following:
 - `action` - (Optional) The action to take. Possible values are `Allow` or `Deny`. Defaults to `Allow`.
 - `ip_address` - (Optional) The CIDR notation of the IP or IP Range to match. For example: `10.0.0.0/24` or `192.168.10.1/32`
 - `name` - (Optional) The name which should be used for this `ip_restriction`.
 - `priority` - (Optional) The priority value of this `ip_restriction`. Defaults to `65000`.
 - `service_tag` - (Optional) The Service Tag used for this IP Restriction.
 - `virtual_network_subnet_id` - (Optional) The Virtual Network Subnet ID used for this IP Restriction.

 ---
 `headers` block supports the following:
 - `x_azure_fdid` - (Optional) Specifies a list of Azure Front Door IDs.
 - `x_fd_health_probe` - (Optional) Specifies if a Front Door Health Probe should be expected. The only possible value is `1`.
 - `x_forwarded_for` - (Optional) Specifies a list of addresses for which matching should be applied. Omitting this value means allow any.
 - `x_forwarded_host` - (Optional) Specifies a list of Hosts for which matching should be applied.

 ---
 `scm_ip_restriction` block supports the following:
 - `action` - (Optional) The action to take. Possible values are `Allow` or `Deny`. Defaults to `Allow`.
 - `ip_address` - (Optional) The CIDR notation of the IP or IP Range to match. For example: `10.0.0.0/24` or `192.168.10.1/32`
 - `name` - (Optional) The name which should be used for this `ip_restriction`.
 - `priority` - (Optional) The priority value of this `ip_restriction`. Defaults to `65000`.
 - `service_tag` - (Optional) The Service Tag used for this IP Restriction.
 - `virtual_network_subnet_id` - (Optional) The Virtual Network Subnet ID used for this IP Restriction.

 ---
 `headers` block supports the following:
 - `x_azure_fdid` - (Optional) Specifies a list of Azure Front Door IDs.
 - `x_fd_health_probe` - (Optional) Specifies if a Front Door Health Probe should be expected. The only possible value is `1`.
 - `x_forwarded_for` - (Optional) Specifies a list of addresses for which matching should be applied. Omitting this value means allow any.
 - `x_forwarded_host` - (Optional) Specifies a list of Hosts for which matching should be applied.

  DESCRIPTION
}

variable "sticky_settings" {
  type = map(object({
    app_setting_names       = optional(list(string))
    connection_string_names = optional(list(string))
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of sticky settings to assign to the Function App.
  - `app_setting_names` - (Optional) A list of app setting names to make sticky.
  - `connection_string_names` - (Optional) A list of connection string names to make sticky.

  ```terraform
  sticky_settings = {
    sticky1 = {
      app_setting_names       = ["example1", "example2"]
      connection_string_names = ["example1", "example2"]
    }
  }
  DESCRIPTION
}

variable "storage_account_access_key" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  The access key of the Storage Account to deploy the Function App in. Conflicts with `storage_uses_managed_identity` (non-flex consumption function app configurations).
  This will resolve to `storage_acccess_key` for flex consumption function apps. Must be specified if `storage_authentication_type` is set to `storageaccountconnecionstring` Conflicts with `storage_user_assigned_identity_id`.
  DESCRIPTION
  sensitive   = true
}

variable "storage_account_name" {
  type        = string
  default     = null
  description = "The name of the Storage Account to deploy the Function App in."
}

variable "storage_account_share_name" {
  type        = string
  default     = null
  description = "(Logic App)"
}

variable "storage_authentication_type" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  The authentication type which will be used to access the backend storage account for the Function App.
  Possible values are `StorageAccountConnectionString`, `SystemAssignedIdentity`, and `UserAssignedIdentity`."
  DESCRIPTION
}

variable "storage_container_endpoint" {
  type        = string
  default     = null
  description = "The backend storage container endpoint which will be used by this Function App."
}

variable "storage_container_type" {
  type        = string
  default     = null
  description = "The storage container type used for the Function App. The current supported type is `blobContainer`."
}

variable "storage_key_vault_secret_id" {
  type        = string
  default     = null
  description = "The ID of the secret in the key vault to use for the Storage Account access key."
}

variable "storage_shares_to_mount" {
  type = map(object({
    access_key   = string
    account_name = string
    mount_path   = string
    name         = string
    share_name   = string
    type         = optional(string, "AzureFiles")
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of objects that represent Storage Account FILE SHARES to mount to the Function App.
  This functionality is only available for Linux Function Apps, via [documentation](https://learn.microsoft.com/en-us/azure/azure-functions/storage-considerations?tabs=azure-cli)

  The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `access_key` - (Optional) The access key of the Storage Account.
  - `account_name` - (Optional) The name of the Storage Account.
  - `name` - (Optional) The name of the Storage Account to mount.
  - `share_name` - (Optional) The name of the share to mount.
  - `type` - (Optional) The type of Storage Account. Currently, only a `type` of `AzureFiles` is supported. Defaults to `AzureFiles`.
  - `mount_path` - (Optional) The path to mount the Storage Account to.

  ```terraform
  storage_accounts = {
    storacc1 = {
      access_key   = "00000000-0000-0000-0000-000000000000"
      account_name = "example"
      name         = "example"
      share_name   = "example"
      type         = "AzureFiles"
      mount_path   = "/mnt/example"
    }
  }
  ```
  DESCRIPTION
}

variable "storage_uses_managed_identity" {
  type        = bool
  default     = false
  description = "Should the Storage Account use a Managed Identity? Conflicts with `storage_account_access_key`."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "The map of tags to be applied to the resource"
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Linux Function App.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Linux Function App.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Linux Function App.
 - `update` - (Defaults to 30 minutes) Used when updating the Linux Function App.
EOT
}

variable "use_extension_bundle" {
  type        = bool
  default     = true
  description = "Should the extension bundle be used? (Logic App)"
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet to deploy the Function App in."
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = true
  description = "Should basic authentication be enabled for web deploy?"
}

variable "zip_deploy_file" {
  type        = string
  default     = null
  description = "The path to the zip file to deploy to the Function App."
}
