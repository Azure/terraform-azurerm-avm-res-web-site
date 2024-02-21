# Required Inputs
variable "name" {
  type        = string
  description = "The name which should be used for the Function App."
}

variable "os_type" {
  type        = string
  description = "The operating system that should be the same type of the App Service Plan to deploy the Function App in."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where the Function App will be deployed."
}

variable "service_plan_resource_id" {
  type        = string
  description = "The resource ID of the App Service Plan to deploy the Function App in."
}

# Optional Inputs
variable "app_settings" {
  type = map(string)
  default = {

  }
  description = <<DESCRIPTION
  A map of key-value pairs for App Settings and custom values to assign to the Function App. 
  
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

variable "auth_settings" {
  type = map(object({
    enabled = optional(bool, false)
    active_directory = optional(map(object({
      client_id                  = optional(string)
      allowed_audiences          = optional(list(string))
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
    })))
    additional_login_parameters    = optional(list(string))
    allowed_external_redirect_urls = optional(list(string))
    default_provider               = optional(string)
    facebook = optional(map(object({
      app_id                  = optional(string)
      app_secret              = optional(string)
      app_secret_setting_name = optional(string)
      oauth_scopes            = optional(list(string))
    })))
    github = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })))
    google = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })))
    issuer = optional(string)
    microsoft = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })))
    runtime_version               = optional(string)
    token_refresh_extension_hours = optional(number, 72)
    token_store_enabled           = optional(bool, false)
    twitter = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret              = optional(string)
      consumer_secret_setting_name = optional(string)
    })))
    unauthenticated_client_action = optional(string)
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of authentication settings to assign to the Function App. 
  - `enabled` - (Optional) Is authentication enabled for the Function App? Defaults to `false`.
  - `active_directory` - (Optional) A map of active directory settings.
  - `additional_login_parameters` - (Optional) A list of additional login parameters.
  - `allowed_external_redirect_urls` - (Optional) A list of allowed external redirect URLs.
  - `default_provider` - (Optional) The default provider for the Function App.
  - `facebook` - (Optional) A map of Facebook settings.
  - `github` - (Optional) A map of GitHub settings.
  - `google` - (Optional) A map of Google settings. 
  - `issuer` - (Optional) The issuer for the Function App.
  - `microsoft` - (Optional) A map of Microsoft settings.
  - `runtime_version` - (Optional) The runtime version for the Function App.
  - `token_refresh_extension_hours` - (Optional) The token refresh extension hours for the Function App. Defaults to `72`.
  - `token_store_enabled` - (Optional) Is the token store enabled for the Function App? Defaults to `false`.
  - `twitter` - (Optional) A map of Twitter settings. 
  - `unauthenticated_client_action` - (Optional) The unauthenticated client action for the Function App.
  
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
    runtime_version                         = optional(string, "~1")
    config_file_path                        = optional(string)
    require_authentication                  = optional(bool, false)
    unauthenticated_action                  = optional(string, "RedirectToLoginPage")
    default_provider                        = optional(string)
    excluded_paths                          = optional(list(string))
    require_https                           = optional(bool, true)
    http_route_api_prefix                   = optional(string, "/.auth")
    forward_proxy_convention                = optional(string, "NoProxy")
    forward_proxy_custom_host_header_name   = optional(string)
    forward_proxy_custom_scheme_header_name = optional(string)
    apple_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })))
    active_directory_v2 = optional(map(object({
      client_id                            = optional(string)
      client_secret_setting_name           = optional(string)
      client_secret_certificate_thumbprint = optional(string)
      tenant_auth_endpoint                 = optional(string)
      allowed_applications                 = optional(list(string))
      allowed_identities                   = optional(list(string))
      allowed_groups                       = optional(list(string))
      allowed_audiences                    = optional(list(string))
      jwt_allowed_client_applications      = optional(list(string))
      jwt_allowed_groups                   = optional(list(string))
      login_parameters                     = optional(map(any))
      www_authentication_disabled          = optional(bool, false)
    })))
    azure_static_web_app_v2 = optional(map(object({
      client_id = optional(string)
    })))
    custom_oidc_v2 = optional(map(object({
      name                          = optional(string)
      client_id                     = optional(string)
      openid_configuration_endpoint = optional(string)
      scopes                        = optional(list(string))
      client_credential_method      = optional(string)
      client_secret_setting_name    = optional(string)
      authorization_endpoint        = optional(string)
      token_endpoint                = optional(string)
      issuer_endpoint               = optional(string)
      certification_uri             = optional(string)
      name_claim_type               = optional(string)

    })))
    facebook_v2 = optional(map(object({
      app_id                  = optional(string)
      app_secret_setting_name = optional(string)
      graph_api_version       = optional(string)
      login_scopes            = optional(list(string))
    })))
    github_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })))
    google_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })))
    microsoft_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })))
    twitter_v2 = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret_setting_name = optional(string)
    })))
    login = map(object({
      logout_endpoint                   = optional(string)
      token_store_enabled               = optional(bool, false)
      token_refresh_extension_time      = optional(number, 72)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      preserve_url_fragments_for_logins = optional(bool, false)
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration_convention      = optional(string, "FixedTime")
      cookie_expiration_time            = optional(string, "00:00:00")
      validate_nonce                    = optional(bool, true)
      nonce_expiration_time             = optional(string, "00:05:00")
    }))
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of authentication settings (V2) to assign to the Function App.
  - `auth_enabled` - (Optional) Is authentication enabled for the Function App? Defaults to `false`.
  - `runtime_version` - (Optional) The runtime version for the Function App. Defaults to `~1`.
  - `config_file_path` - (Optional) The path to the config file for the Function App.
  - `require_authentication` - (Optional) Does the Function App require authentication? Defaults to `false`.
  - `unauthenticated_action` - (Optional) The unauthenticated action for the Function App. Defaults to `RedirectToLoginPage`.
  - `default_provider` - (Optional) The default provider for the Function App.
  - `excluded_paths` - (Optional) A list of excluded paths for the Function App.
  - `require_https` - (Optional) Does the Function App require HTTPS? Defaults to `true`.
  - `http_route_api_prefix` - (Optional) The HTTP route API prefix for the Function App. Defaults to `/.auth`.
  - `forward_proxy_convention` - (Optional) The forward proxy convention for the Function App. Defaults to `NoProxy`.
  - `forward_proxy_custom_host_header_name` - (Optional) The forward proxy custom host header name for the Function App.
  - `forward_proxy_custom_scheme_header_name` - (Optional) The forward proxy custom scheme header name for the Function App.
  - `apple_v2` - (Optional) A map of Apple settings.
  - `active_directory_v2` - (Optional) A map of Active Directory settings.
  - `azure_static_web_app_v2` - (Optional) A map of Azure Static Web App settings.
  - `custom_oidc_v2` - (Optional) A map of custom OIDC settings.
  - `facebook_v2` - (Optional) A map of Facebook settings.
  - `github_v2` - (Optional) A map of GitHub settings.
  - `google_v2` - (Optional) A map of Google settings.
  - `microsoft_v2` - (Optional) A map of Microsoft settings.
  - `twitter_v2` - (Optional) A map of Twitter settings.
  - `login` - (Optional) A map of login settings.

  ```terraform
  auth_settings_v2 = {
    example = {
      auth_enabled = true
      active_directory_v2 = {
        client_id                  = "00000000-0000-0000-0000-000000000000"
        client_secret_setting_name = "00000000-0000-0000-0000-000000000000"
        login_scopes               = ["00000000-0000-0000-0000-000000000000"]
      }
    }
  }
  ```
  DESCRIPTION
}

variable "backup" {
  type = map(object({
    name = optional(string)
    schedule = optional(map(object({
      frequency_interval       = optional(number)
      frequency_unit           = optional(string)
      keep_at_least_one_backup = optional(bool)
      retention_period_in_days = optional(number)
      start_time               = optional(string)
    })))
    storage_account_url = optional(string)
    enabled             = optional(bool, true)
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
  default     = "Optional"
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

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id              = optional(string)
    key_name                           = optional(string)
    key_version                        = optional(string, null)
    user_assigned_identity_resource_id = optional(string, null)
  })
  default     = {}
  description = <<DESCRIPTION
  The Customer Managed Keys that should be associated with the Function App.
  - `key_vault_resource_id` - (Optional) The resource ID of the Key Vault to use for the Customer Managed Key.
  - `key_name` - (Optional) The name of the key in the Key Vault.
  - `key_version` - (Optional) The version of the key in the Key Vault.
  - `user_assigned_identity_resource_id` - (Optional) The resource ID of the User Assigned Identity to use for the Customer Managed Key.
  ```terraform
  customer_managed_key = {
    key_vault_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.KeyVault/vaults/example"
    key_name                           = "example"
    key_version                        = "00000000-0000-0000-0000-000000000000"
    user_assigned_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example"
  }
  ```
  DESCRIPTION
}

variable "daily_memory_time_quota" {
  type        = number
  default     = 0
  description = "(Optional) The amount of memory in gigabyte-seconds that your application is allowed to consume per day. Setting this value only affects Function Apps under the consumption plan. Defaults to 0."
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
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
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
  description = "Is the Function App enabled? Defaults to true."
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  default     = true
  description = "Should basic authentication be enabled for FTP publish?"
}

variable "functions_extension_version" {
  type        = string
  default     = "~4"
  description = "The version of the Azure Functions runtime to use. Defaults to ~3."
}

variable "https_only" {
  type        = bool
  default     = false
  description = "Should the Function App only be accessible over HTTPS?"
}

variable "identities" {
  type = map(object({
    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string))
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of identities to assign to the resource. 
  The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  DESCRIPTION
}

variable "key_vault_reference_identity_id" {
  type        = string
  default     = null
  description = "The identity ID to use for Key Vault references."
}

variable "location" {
  type        = string
  default     = null
  description = "Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
  default     = {}
  description = "The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."
  nullable    = false

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identities to be created for the resource."
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
    })), {})
    lock = optional(object({
      name = optional(string, null)
      kind = optional(string, "None")
    }), {})
    tags                                    = optional(map(any), null)
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
    inherit_lock = optional(bool, true)
    inherit_tags = optional(bool, true)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
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
- `inherit_lock` - (Optional) Should the private endpoint inherit the lock from the parent resource? Defaults to `true`.
- `inherit_tags` - (Optional) Should the private endpoint inherit the tags from the parent resource? Defaults to `true`.
DESCRIPTION
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
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
}

variable "site_config" {
  type = object({
    always_on                              = optional(bool, false) # when running in a Consumption or Premium Plan, `always_on` feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
    api_definition_url                     = optional(string)      # (Optional) The URL of the OpenAPI (Swagger) definition that provides schema for the function's HTTP endpoints.
    api_management_api_id                  = optional(string)      # (Optional) The API Management API identifier.
    app_command_line                       = optional(string)      # (Optional) The command line to launch the application.
    app_scale_limit                        = optional(number)      # (Optional) The maximum number of workers that the Function App can scale out to.
    application_insights_connection_string = optional(string)      # (Optional) The connection string of the Application Insights resource to send telemetry to.
    application_insights_key               = optional(string)      # (Optional) The instrumentation key of the Application Insights resource to send telemetry to.
    application_stack = optional(map(object({
      dotnet_version              = optional(string, "v4.0")
      use_dotnet_isolated_runtime = optional(bool, false)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
      use_custom_runtime          = optional(bool, false)
    })), {})
    app_service_logs = optional(map(object({
      disk_quota_mb         = optional(number, 35)
      retention_period_days = optional(number)
    })), {})
    cors = optional(map(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool, false)
    })), {})                                                         #(Optional) A cors block as defined above.
    default_documents                 = optional(list(string))       #(Optional) Specifies a list of Default Documents for the Windows Function App.
    elastic_instance_minimum          = optional(number)             #(Optional) The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
    ftps_state                        = optional(string, "Disabled") #(Optional) State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
    health_check_path                 = optional(string)             #(Optional) The path to be checked for this Windows Function App health.
    health_check_eviction_time_in_min = optional(number)             #(Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path.
    http2_enabled                     = optional(bool, false)        #(Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to false.
    ip_restriction = optional(map(object({
      action = optional(string, "Allow")
      headers = optional(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(number)
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      }), {})
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
    })), {})                                                             #(Optional) One or more ip_restriction blocks as defined above.
    load_balancing_mode              = optional(string, "LeastRequests") #(Optional) The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests if omitted.
    managed_pipeline_mode            = optional(string, "Integrated")    #(Optional) Managed pipeline mode. Possible values include: Integrated, Classic. Defaults to Integrated.
    minimum_tls_version              = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
    pre_warmed_instance_count        = optional(number)                  #(Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
    remote_debugging_enabled         = optional(bool, false)             #(Optional) Should Remote Debugging be enabled. Defaults to false.
    remote_debugging_version         = optional(string)                  #(Optional) The Remote Debugging Version. Possible values include VS2017, VS2019, and VS2022.
    runtime_scale_monitoring_enabled = optional(bool)                    #(Optional) Should runtime scale monitoring be enabled.
    scm_ip_restriction = optional(map(object({
      action = optional(string, "Allow")
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(number)
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
    })), {})                                              #(Optional) One or more scm_ip_restriction blocks as defined above.
    scm_minimum_tls_version     = optional(string, "1.2") #(Optional) Configures the minimum version of TLS required for SSL requests to Kudu. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
    scm_use_main_ip_restriction = optional(bool, false)   #(Optional) Should the SCM use the same IP restrictions as the main site. Defaults to false.
    use_32_bit_worker           = optional(bool, true)    #(Optional) Should the 32-bit worker process be used. Defaults to false.
    vnet_route_all_enabled      = optional(bool, false)   #(Optional) Should all traffic be routed to the virtual network. Defaults to false.
    websockets_enabled          = optional(bool, false)   #(Optional) Should Websockets be enabled. Defaults to false.
    worker_count                = optional(number)        #(Optional) The number of workers for this Windows Function App. Only affects apps on an Elastic Premium plan.
  })
  default = {

  }
  description = <<DESCRIPTION
  An object that configures the Function App's `site_config` block.
  -`always_on` - (Optional) Is the Function App always on? Defaults to `false`.
  -`api_definition_url` - (Optional) The URL of the OpenAPI (Swagger) definition that provides schema for the function's HTTP endpoints.
  -`api_management_api_id` - (Optional) The API Management API identifier.
  -`app_command_line` - (Optional) The command line to launch the application.
  -`app_scale_limit` - (Optional) The maximum number of workers that the Function App can scale out to.

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
  description = "The access key of the Storage Account to deploy the Function App in."
}

variable "storage_account_name" {
  type        = string
  default     = null
  description = "The name of the Storage Account to deploy the Function App in."
}

variable "storage_accounts" {
  type = map(object({
    access_key   = optional(string)
    account_name = optional(string)
    name         = optional(string)
    share_name   = optional(string)
    type         = optional(string, "AzureFiles")
    mount_path   = optional(string)
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of objects that represent Storage Accounts to mount to the Function App.
  The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `access_key` - (Optional) The access key of the Storage Account.
  - `account_name` - (Optional) The name of the Storage Account.
  - `name` - (Optional) The name of the Storage Account to mount.
  - `share_name` - (Optional) The name of the share to mount.
  - `type` - (Optional) The type of Storage Account. Defaults to `AzureFiles`.
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

variable "storage_key_vault_secret_id" {
  type        = string
  default     = null
  description = "The ID of the secret in the key vault to use for the Storage Account access key."
}

variable "storage_uses_managed_identity" {
  type        = bool
  default     = false
  description = "Should the Storage Account use a Managed Identity?"
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(any)
  default     = {}
  description = "The map of tags to be applied to the resource"
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
