variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name which should be used for the App Service."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the Resource Group where the App Service will be deployed."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure Resource Group resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}

variable "service_plan_resource_id" {
  type        = string
  description = "The resource ID of the App Service Plan to deploy the App Service in."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service Plan resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/serverFarms/{serverFarmName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/[sS]erver[fF]arms/[a-zA-Z0-9._-]+$", var.service_plan_resource_id))
  }
}

variable "all_child_resources_inherit_tags" {
  type        = bool
  default     = true
  description = "Should child resources inherit tags from the parent resource? Defaults to `true`."
}

variable "always_ready" {
  type = map(object({
    name           = optional(string)
    instance_count = optional(number, 0)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of always-ready instances for Flex Consumption Function Apps.
- `name`: The trigger type or function name. Valid values: `http`, `blob`, `durable`, `function:<target-function-app-name>`.
- `instance_count`: The number of always-ready instances. Defaults to `0`.
DESCRIPTION
}

variable "app_service_active_slot" {
  type = object({
    slot_key                 = optional(string)
    overwrite_network_config = optional(bool, true)
  })
  default     = null
  description = <<DESCRIPTION
Object that sets the active slot for the App Service.

- `slot_key` - The key of the slot object to set as active.
- `overwrite_network_config` - Determines if the network configuration should be overwritten. Defaults to `true`.
DESCRIPTION
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
A map of key-value pairs for App Settings and custom values to assign to the App Service.
These are set via the `Microsoft.Web/sites/config` (name: `appsettings`) sub-resource.
DESCRIPTION
}

variable "application_insights" {
  type = object({
    application_type                      = optional(string, "web")
    inherit_tags                          = optional(bool, false)
    location                              = optional(string)
    name                                  = optional(string)
    parent_id                             = optional(string)
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
  default     = {}
  description = <<DESCRIPTION
The Application Insights settings for the App Service.

- `application_type` - The type of Application Insights. Defaults to `web`.
- `inherit_tags` - Should Application Insights inherit tags from the parent? Defaults to `false`.
- `location` - The location of the Application Insights.
- `name` - The name of the Application Insights.
- `parent_id` - (Optional) The resource ID of the Resource Group for Application Insights. Defaults to `var.parent_id`.
- `tags` - (Optional) Tags to apply to the Application Insights resource.
- `workspace_resource_id` - The Log Analytics Workspace resource ID.
- `daily_data_cap_in_gb` - (Optional) The daily data volume cap in GB.
- `daily_data_cap_notifications_disabled` - (Optional) Should notifications be disabled when the daily data cap is reached?
- `retention_in_days` - (Optional) The retention period in days. Defaults to `90`.
- `sampling_percentage` - (Optional) The percentage of telemetry items to sample. Defaults to `100`.
- `disable_ip_masking` - (Optional) Should IP masking be disabled? Defaults to `false`.
- `local_authentication_disabled` - (Optional) Should local authentication be disabled? Defaults to `false`.
- `internet_ingestion_enabled` - (Optional) Should internet ingestion be enabled? Defaults to `true`.
- `internet_query_enabled` - (Optional) Should internet query be enabled? Defaults to `true`.
- `force_customer_storage_for_profiler` - (Optional) Should customer storage be forced for the profiler? Defaults to `false`.
DESCRIPTION
}

variable "auth_settings" {
  type = object({
    additional_login_parameters    = optional(map(string))
    allowed_external_redirect_urls = optional(list(string))
    default_provider               = optional(string)
    enabled                        = optional(bool, false)
    issuer                         = optional(string)
    runtime_version                = optional(string)
    token_refresh_extension_hours  = optional(number, 72)
    token_store_enabled            = optional(bool, false)
    unauthenticated_client_action  = optional(string)
    active_directory = optional(object({
      client_id                  = optional(string)
      allowed_audiences          = optional(list(string))
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
    }))
    facebook = optional(object({
      app_id                  = optional(string)
      app_secret              = optional(string)
      app_secret_setting_name = optional(string)
      oauth_scopes            = optional(list(string))
    }))
    github = optional(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    }))
    google = optional(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    }))
    microsoft = optional(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    }))
    twitter = optional(object({
      consumer_key                 = optional(string)
      consumer_secret              = optional(string)
      consumer_secret_setting_name = optional(string)
    }))
  })
  default     = null
  description = <<DESCRIPTION
A map of authentication settings to assign to the App Service.

- `additional_login_parameters` - (Optional) A map of additional login parameters.
- `allowed_external_redirect_urls` - (Optional) A list of allowed external redirect URLs.
- `default_provider` - (Optional) The default authentication provider.
- `enabled` - (Optional) Is authentication enabled? Defaults to `false`.
- `issuer` - (Optional) The issuer URI.
- `runtime_version` - (Optional) The runtime version of the authentication module.
- `token_refresh_extension_hours` - (Optional) Hours before token expiry to refresh. Defaults to `72`.
- `token_store_enabled` - (Optional) Should the token store be enabled? Defaults to `false`.
- `unauthenticated_client_action` - (Optional) The action to take for unauthenticated requests.
- `active_directory` - (Optional) An Active Directory authentication block.
  - `client_id` - (Optional) The Client ID of the Azure AD application.
  - `allowed_audiences` - (Optional) A list of allowed audience values.
  - `client_secret` - (Optional) The Client Secret of the Azure AD application.
  - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
- `facebook` - (Optional) A Facebook authentication block.
  - `app_id` - (Optional) The App ID of the Facebook application.
  - `app_secret` - (Optional) The App Secret of the Facebook application.
  - `app_secret_setting_name` - (Optional) The app setting name that contains the app secret.
  - `oauth_scopes` - (Optional) A list of OAuth scopes to request.
- `github` - (Optional) A GitHub authentication block.
  - `client_id` - (Optional) The Client ID of the GitHub application.
  - `client_secret` - (Optional) The Client Secret of the GitHub application.
  - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
  - `oauth_scopes` - (Optional) A list of OAuth scopes to request.
- `google` - (Optional) A Google authentication block.
  - `client_id` - (Optional) The Client ID of the Google application.
  - `client_secret` - (Optional) The Client Secret of the Google application.
  - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
  - `oauth_scopes` - (Optional) A list of OAuth scopes to request.
- `microsoft` - (Optional) A Microsoft authentication block.
  - `client_id` - (Optional) The Client ID of the Microsoft application.
  - `client_secret` - (Optional) The Client Secret of the Microsoft application.
  - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
  - `oauth_scopes` - (Optional) A list of OAuth scopes to request.
- `twitter` - (Optional) A Twitter authentication block.
  - `consumer_key` - (Optional) The consumer key of the Twitter application.
  - `consumer_secret` - (Optional) The consumer secret of the Twitter application.
  - `consumer_secret_setting_name` - (Optional) The app setting name that contains the consumer secret.
DESCRIPTION
}

variable "auth_settings_v2" {
  type = object({
    auth_enabled                           = optional(bool, false)
    config_file_path                       = optional(string)
    excluded_paths                         = optional(list(string))
    forward_proxy_convention               = optional(string, "NoProxy")
    forward_proxy_custom_host_header_name  = optional(string)
    forward_proxy_custom_proto_header_name = optional(string)
    http_route_api_prefix                  = optional(string, "/.auth")
    redirect_to_provider                   = optional(string)
    require_authentication                 = optional(bool, false)
    require_https                          = optional(bool, true)
    runtime_version                        = optional(string, "~1")
    unauthenticated_client_action          = optional(string, "RedirectToLoginPage")
    identity_providers = optional(object({
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
    }))
    login = optional(object({
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
    }))
  })
  default     = null
  description = <<DESCRIPTION
Authentication settings V2 configuration for the App Service. Mirrors the API structure.

- `auth_enabled` - (Optional) Is authentication enabled? Defaults to `false`.
- `config_file_path` - (Optional) The path to the auth configuration file.
- `excluded_paths` - (Optional) A list of paths excluded from authentication.
- `forward_proxy_convention` - (Optional) The convention for forwarding proxy headers. Defaults to `NoProxy`.
- `forward_proxy_custom_host_header_name` - (Optional) The custom host header name for the forward proxy.
- `forward_proxy_custom_proto_header_name` - (Optional) The custom proto header name for the forward proxy.
- `http_route_api_prefix` - (Optional) The prefix for the HTTP route API. Defaults to `/.auth`.
- `redirect_to_provider` - (Optional) The default authentication provider when multiple providers are configured.
- `require_authentication` - (Optional) Should authentication be required? Defaults to `false`.
- `require_https` - (Optional) Should HTTPS be required? Defaults to `true`.
- `runtime_version` - (Optional) The runtime version of the auth module. Defaults to `~1`.
- `unauthenticated_client_action` - (Optional) The action for unauthenticated requests. Defaults to `RedirectToLoginPage`.
- `identity_providers` - (Optional) The identity providers configuration. See variable description in the submodule for full details.
- `login` - (Optional) The login configuration. See variable description in the submodule for full details.
DESCRIPTION
}

variable "auto_generated_domain_name_label_scope" {
  type        = string
  default     = null
  description = "(Optional) The scope of the auto-generated domain name label. Possible values are `NoReuse`, `ResourceGroupReuse`, `SubscriptionReuse`, and `TenantReuse`."

  validation {
    error_message = "The value must be one of: `NoReuse`, `ResourceGroupReuse`, `SubscriptionReuse`, or `TenantReuse`."
    condition     = var.auto_generated_domain_name_label_scope == null || can(index(["NoReuse", "ResourceGroupReuse", "SubscriptionReuse", "TenantReuse"], var.auto_generated_domain_name_label_scope))
  }
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
  default     = {}
  description = <<DESCRIPTION
A map of backup settings for the App Service.

- `enabled` - (Optional) Is backup enabled? Defaults to `true`.
- `name` - (Optional) The name of the backup.
- `storage_account_url` - (Optional) The SAS URL to the Storage Account container for backup.
- `schedule` - (Optional) A map of backup schedule settings.
  - `frequency_interval` - (Optional) How often the backup should be executed.
  - `frequency_unit` - (Optional) The unit of time for the backup frequency. Possible values are `Day` and `Hour`.
  - `keep_at_least_one_backup` - (Optional) Should at least one backup always be kept?
  - `retention_period_days` - (Optional) The number of days to retain backups.
  - `start_time` - (Optional) The start time for the backup schedule.
DESCRIPTION
}

variable "builtin_logging_enabled" {
  type        = bool
  default     = true
  description = "Should builtin logging be enabled for the Function App? Defaults to `true`."
}

variable "bundle_version" {
  type        = string
  default     = "[1.*, 2.0.0)"
  description = "The version of the extension bundle to use. Defaults to `[1.*, 2.0.0)`. (Logic App)"
}

variable "client_affinity_enabled" {
  type        = bool
  default     = false
  description = "Should client affinity be enabled for the App Service? Defaults to `false`."
}

variable "client_affinity_partitioning_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should client affinity partitioning (CHIPS cookie partitioning) be enabled? When enabled, the affinity cookie uses the CHIPS partitioned attribute."
}

variable "client_affinity_proxy_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should client affinity proxy be enabled? When enabled, the `X-Forwarded-Host` header overrides the host value used for affinity cookie routing."
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Should client certificate be enabled for the App Service? Defaults to `false`."
}

variable "client_certificate_exclusion_paths" {
  type        = string
  default     = null
  description = "The client certificate exclusion paths for the App Service."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "The client certificate mode for the App Service. Possible values are `Required`, `Optional`, and `OptionalInteractiveUser`. Defaults to `Required`."
}

variable "connection_strings" {
  type = map(object({
    name  = optional(string)
    type  = optional(string)
    value = optional(string)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of connection strings to assign to the App Service.
- `name` - (Optional) The name of the connection string.
- `type` - (Optional) The type of the connection string.
- `value` - (Optional) The value of the connection string.
DESCRIPTION
}

variable "container_size" {
  type        = number
  default     = null
  description = "(Optional) The size of the function container in MB. Only applicable to Function Apps under a Consumption plan."
}

variable "content_share_force_disabled" {
  type        = bool
  default     = false
  description = "Should content share be force disabled for the Function App? Defaults to `false`."
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
    thumbprint                   = optional(string)
    thumbprint_key               = optional(string)
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
  default     = {}
  description = <<DESCRIPTION
A map of custom domains to assign to the App Service.

- `slot_as_target` - (Optional) Should the slot be used as the target? Defaults to `false`.
- `app_service_slot_key` - (Optional) The key of the deployment slot to target.
- `create_certificate` - (Optional) Should a managed certificate be created? Defaults to `false`.
- `certificate_name` - (Optional) The name of the certificate.
- `certificate_location` - (Optional) The location of the certificate.
- `pfx_blob` - (Optional) The PFX blob for the certificate.
- `pfx_password` - (Optional) The password for the PFX certificate.
- `hostname` - (Optional) The custom domain hostname.
- `app_service_name` - (Optional) The App Service name.
- `app_service_plan_resource_id` - (Optional) The resource ID of the App Service Plan.
- `key_vault_secret_id` - (Optional) The Key Vault secret ID for the certificate.
- `key_vault_id` - (Optional) The Key Vault ID for the certificate.
- `zone_resource_group_name` - (Optional) The resource group of the DNS zone.
- `resource_group_name` - (Optional) The resource group name.
- `ssl_state` - (Optional) The SSL state. Possible values are `IpBasedEnabled` and `SniEnabled`.
- `inherit_tags` - (Optional) Should tags be inherited from the parent? Defaults to `true`.
- `tags` - (Optional) Tags to apply to the custom domain resources.
- `thumbprint` - (Optional) The certificate thumbprint value.
- `thumbprint_key` - (Optional) The key to look up the certificate thumbprint.
- `ttl` - (Optional) The TTL for DNS records. Defaults to `300`.
- `validation_type` - (Optional) The domain validation type. Defaults to `cname-delegation`.
- `create_cname_records` - (Optional) Should CNAME records be created? Defaults to `false`.
- `cname_name` - (Optional) The CNAME record name.
- `cname_zone_name` - (Optional) The DNS zone name for the CNAME record.
- `cname_record` - (Optional) The CNAME record value.
- `cname_target_resource_id` - (Optional) The target resource ID for the CNAME record.
- `create_txt_records` - (Optional) Should TXT records be created? Defaults to `false`.
- `txt_name` - (Optional) The TXT record name.
- `txt_zone_name` - (Optional) The DNS zone name for the TXT record.
- `txt_records` - (Optional) A map of TXT records with `value` attribute.
DESCRIPTION
}

variable "daily_memory_time_quota" {
  type        = number
  default     = 0
  description = "(Optional) The amount of memory in gigabyte-seconds that your application is allowed to consume per day. Setting this value only affects Function Apps under the consumption plan. Defaults to `0`."
}

variable "dapr_config" {
  type = object({
    app_id                = optional(string)
    app_port              = optional(number)
    enable_api_logging    = optional(bool)
    enabled               = optional(bool)
    http_max_request_size = optional(number)
    http_read_buffer_size = optional(number)
    log_level             = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Dapr configuration for the App Service. Only applicable to apps hosted in Azure Container Apps environments.

- `app_id` - (Optional) The Dapr app identifier.
- `app_port` - (Optional) The port the application is listening on.
- `enable_api_logging` - (Optional) Should API logging be enabled for Dapr?
- `enabled` - (Optional) Is Dapr enabled?
- `http_max_request_size` - (Optional) The maximum size of HTTP request body in MB.
- `http_read_buffer_size` - (Optional) The maximum size of HTTP header read buffer in KB.
- `log_level` - (Optional) The Dapr log level. Possible values are `debug`, `error`, `info`, and `warn`.
DESCRIPTION

  validation {
    error_message = "The log_level must be one of: `debug`, `error`, `info`, or `warn`."
    condition     = var.dapr_config == null || var.dapr_config.log_level == null || can(index(["debug", "error", "info", "warn"], var.dapr_config.log_level))
  }
}

variable "deployment_slots" {
  type = map(object({
    name                                   = optional(string)
    auto_generated_domain_name_label_scope = optional(string)
    client_affinity_enabled                = optional(bool, false)
    client_affinity_partitioning_enabled   = optional(bool)
    client_affinity_proxy_enabled          = optional(bool)
    client_certificate_enabled             = optional(bool, false)
    client_certificate_exclusion_paths     = optional(string, null)
    client_certificate_mode                = optional(string, "Required")
    container_size                         = optional(number)
    dapr_config = optional(object({
      app_id                = optional(string)
      app_port              = optional(number)
      enable_api_logging    = optional(bool)
      enabled               = optional(bool)
      http_max_request_size = optional(number)
      http_read_buffer_size = optional(number)
      log_level             = optional(string)
    }))
    dns_configuration = optional(object({
      dns_alt_server            = optional(string)
      dns_max_cache_timeout     = optional(number)
      dns_retry_attempt_count   = optional(number)
      dns_retry_attempt_timeout = optional(number)
      dns_servers               = optional(list(string))
    }))
    enabled                                  = optional(bool, true)
    end_to_end_encryption_enabled            = optional(bool)
    ftp_publish_basic_authentication_enabled = optional(bool, false)
    hosting_environment_id                   = optional(string)
    host_names_disabled                      = optional(bool)
    https_only                               = optional(bool, true)
    hyper_v                                  = optional(bool)
    ip_mode                                  = optional(string)
    key_vault_reference_identity             = optional(string, null)
    managed_environment_id                   = optional(string)
    public_network_access_enabled            = optional(bool, false)
    redundancy_mode                          = optional(string)
    resource_config = optional(object({
      cpu    = optional(number)
      memory = optional(string)
    }))
    scm_site_also_stopped                          = optional(bool)
    server_farm_id                                 = optional(string, null)
    ssh_enabled                                    = optional(bool)
    storage_account_required                       = optional(bool)
    tags                                           = optional(map(string))
    virtual_network_subnet_id                      = optional(string, null)
    vnet_route_all_traffic                         = optional(bool, false)
    vnet_application_traffic_enabled               = optional(bool, false)
    vnet_backup_restore_enabled                    = optional(bool, false)
    vnet_content_share_enabled                     = optional(bool, false)
    vnet_image_pull_enabled                        = optional(bool, false)
    webdeploy_publish_basic_authentication_enabled = optional(bool, false)
    workload_profile_name                          = optional(string)
    app_settings                                   = optional(map(string), {})
    site_config = optional(object({
      always_on             = optional(bool, true)
      api_definition_url    = optional(string)
      api_management_api_id = optional(string)
      app_command_line      = optional(string)
      app_scale_limit       = optional(number)
      auto_heal_enabled     = optional(bool)
      auto_heal_rules = optional(object({
        actions = optional(object({
          action_type = string
          custom_action = optional(object({
            exe        = string
            parameters = optional(string)
          }))
          min_process_execution_time = optional(string, "00:00:00")
        }))
        triggers = optional(object({
          private_bytes_in_kb = optional(number)
          requests = optional(object({
            count         = number
            time_interval = string
          }))
          slow_requests = optional(object({
            count         = number
            time_interval = string
            time_taken    = string
            path          = optional(string)
          }))
          slow_requests_with_path = optional(list(object({
            count         = number
            time_interval = string
            time_taken    = string
            path          = optional(string)
          })), [])
          status_codes = optional(list(object({
            count         = number
            time_interval = string
            status        = number
            path          = optional(string)
            sub_status    = optional(number)
            win32_status  = optional(number)
          })), [])
          status_codes_range = optional(list(object({
            count         = number
            time_interval = string
            status_codes  = string
            path          = optional(string)
          })), [])
        }))
      }))
      auto_swap_slot_name                           = optional(string)
      container_registry_managed_identity_client_id = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      cors = optional(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool, false)
      }))
      default_documents              = optional(list(string))
      detailed_error_logging_enabled = optional(bool)
      document_root                  = optional(string)
      dotnet_framework_version       = optional(string, "v4.0")
      elastic_instance_minimum       = optional(number)
      elastic_web_app_scale_limit    = optional(number)
      experiments = optional(object({
        ramp_up_rules = optional(list(object({
          action_host_name             = optional(string)
          change_decision_callback_url = optional(string)
          change_interval_in_minutes   = optional(number)
          change_step                  = optional(number)
          max_reroute_percentage       = optional(number)
          min_reroute_percentage       = optional(number)
          name                         = optional(string)
          reroute_percentage           = optional(number)
        })), [])
      }))
      ftps_state = optional(string, "FtpsOnly")
      handler_mappings = optional(list(object({
        arguments        = optional(string)
        extension        = optional(string)
        script_processor = optional(string)
      })))
      health_check_path    = optional(string)
      http2_enabled        = optional(bool, false)
      http20_proxy_flag    = optional(number)
      http_logging_enabled = optional(bool)
      ip_restriction = optional(list(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string))
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        }))
      })), [])
      ip_restriction_default_action = optional(string, "Allow")
      java_container                = optional(string)
      java_container_version        = optional(string)
      java_version                  = optional(string)
      limits = optional(object({
        max_disk_size_in_mb = optional(number)
        max_memory_in_mb    = optional(number)
        max_percentage_cpu  = optional(number)
      }))
      linux_fx_version                 = optional(string)
      load_balancing_mode              = optional(string, "LeastRequests")
      local_mysql_enabled              = optional(bool, false)
      logs_directory_size_limit        = optional(number)
      managed_pipeline_mode            = optional(string, "Integrated")
      min_tls_cipher_suite             = optional(string)
      minimum_tls_version              = optional(string, "1.3")
      node_version                     = optional(string)
      php_version                      = optional(string)
      powershell_version               = optional(string)
      pre_warmed_instance_count        = optional(number)
      python_version                   = optional(string)
      remote_debugging_enabled         = optional(bool, false)
      remote_debugging_version         = optional(string)
      request_tracing_enabled          = optional(bool)
      request_tracing_expiration_time  = optional(string)
      runtime_scale_monitoring_enabled = optional(bool)
      scm_ip_restriction = optional(list(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string))
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        }))
      })), [])
      scm_ip_restriction_default_action      = optional(string, "Allow")
      scm_minimum_tls_version                = optional(string, "1.2")
      scm_type                               = optional(string, "None")
      scm_use_main_ip_restriction            = optional(bool, false)
      tracing_options                        = optional(string)
      use_32_bit_worker                      = optional(bool, false)
      vnet_private_ports_count               = optional(number)
      vnet_route_all_enabled                 = optional(bool, false)
      website_time_zone                      = optional(string)
      websockets_enabled                     = optional(bool, false)
      windows_fx_version                     = optional(string)
      worker_count                           = optional(number)
      application_insights_connection_string = optional(string)
      application_insights_key               = optional(string)
      slot_application_insights_object_key   = optional(string)
      application_stack = optional(object({
        docker = optional(object({
          docker_image_name   = optional(string)
          docker_registry_url = optional(string)
          docker_image_tag    = optional(string, "latest")
        }))
        dotnet = optional(object({
          dotnet_version              = optional(string)
          current_stack               = optional(string)
          use_custom_runtime          = optional(bool, false)
          use_dotnet_isolated_runtime = optional(bool, false)
        }))
        java = optional(object({
          java_version           = optional(string)
          java_container         = optional(string)
          java_container_version = optional(string)
        }))
        node = optional(object({
          node_version = optional(string)
        }))
        php = optional(object({
          php_version = optional(string)
        }))
        python = optional(object({
          python_version = optional(string)
        }))
        powershell = optional(object({
          powershell_version = optional(string)
        }))
      }))
      virtual_application = optional(list(object({
        physical_path   = optional(string, "site\\wwwroot")
        preload_enabled = optional(bool, false)
        virtual_path    = optional(string, "/")
        virtual_directory = optional(list(object({
          physical_path = optional(string)
          virtual_path  = optional(string)
        })), [])
      })), [])
    }), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    private_endpoints = optional(map(object({
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
    })), {})
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
    storage_shares_to_mount = optional(map(object({
      account_name = string
      mount_path   = string
      name         = string
      share_name   = string
      type         = optional(string, "AzureFiles")
    })), {})
    connection_strings = optional(map(object({
      name  = optional(string)
      type  = optional(string)
      value = optional(string)
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of deployment slots to create for the App Service.

- `name` - (Optional) The name of the slot.
- `auto_generated_domain_name_label_scope` - (Optional) The scope of the auto-generated domain name label.
- `client_affinity_enabled` - (Optional) Should client affinity be enabled? Defaults to `false`.
- `client_affinity_partitioning_enabled` - (Optional) Should client affinity partitioning (CHIPS) be enabled?
- `client_affinity_proxy_enabled` - (Optional) Should client affinity proxy be enabled?
- `client_certificate_enabled` - (Optional) Should client certificates be enabled? Defaults to `false`.
- `client_certificate_exclusion_paths` - (Optional) Paths to exclude from client certificate authentication.
- `client_certificate_mode` - (Optional) The client certificate mode. Defaults to `Required`.
- `container_size` - (Optional) The size of the function container in MB.
- `dapr_config` - (Optional) Dapr configuration object.
- `dns_configuration` - (Optional) DNS configuration object.
- `enabled` - (Optional) Is the slot enabled? Defaults to `true`.
- `end_to_end_encryption_enabled` - (Optional) Should end-to-end encryption be enabled?
- `ftp_publish_basic_authentication_enabled` - (Optional) Should FTP basic authentication be enabled? Defaults to `false`.
- `hosting_environment_id` - (Optional) The resource ID of the App Service Environment.
- `host_names_disabled` - (Optional) Should public hostnames be disabled?
- `https_only` - (Optional) Should the slot only be accessible over HTTPS? Defaults to `true`.
- `hyper_v` - (Optional) Should the slot run in Hyper-V isolation?
- `ip_mode` - (Optional) The IP mode. Possible values: `IPv4`, `IPv4AndIPv6`, `IPv6`.
- `key_vault_reference_identity` - (Optional) The identity to use for Key Vault references.
- `managed_environment_id` - (Optional) The Azure Container Apps managed environment ID.
- `public_network_access_enabled` - (Optional) Should public network access be enabled? Defaults to `false`.
- `redundancy_mode` - (Optional) The site redundancy mode.
- `resource_config` - (Optional) Resource config for Container App environment hosted apps.
- `scm_site_also_stopped` - (Optional) Should the SCM site also be stopped?
- `server_farm_id` - (Optional) The server farm resource ID to use for the slot.
- `ssh_enabled` - (Optional) Should SSH be enabled?
- `storage_account_required` - (Optional) Should a storage account be required?
- `tags` - (Optional) Tags to apply to the slot.
- `virtual_network_subnet_id` - (Optional) The subnet ID for VNet integration.
- `vnet_route_all_traffic` - (Optional) Should all outbound traffic use VNet routing? Defaults to `false`.
- `vnet_application_traffic_enabled` - (Optional) Should application traffic use VNet routing? Defaults to `false`.
- `vnet_backup_restore_enabled` - (Optional) Should backup/restore traffic use VNet routing? Defaults to `false`.
- `vnet_content_share_enabled` - (Optional) Should content share traffic use VNet routing? Defaults to `false`.
- `vnet_image_pull_enabled` - (Optional) Should image pull traffic use VNet routing? Defaults to `false`.
- `webdeploy_publish_basic_authentication_enabled` - (Optional) Should WebDeploy basic authentication be enabled? Defaults to `false`.
- `workload_profile_name` - (Optional) The workload profile name.
- `app_settings` - (Optional) App settings for the slot.
- `site_config` - (Optional) Site configuration for the slot.
  - `always_on` - (Optional) Should the slot always be on? Defaults to `true`.
  - `api_definition_url` - (Optional) The URL of the API definition.
  - `api_management_api_id` - (Optional) The ID of the API Management API.
  - `app_command_line` - (Optional) The App command line to launch.
  - `app_scale_limit` - (Optional) The number of workers this function app can scale out to.
  - `auto_swap_slot_name` - (Optional) The name of the slot to auto swap with.
  - `container_registry_managed_identity_client_id` - (Optional) The Client ID of the MSI for Azure Container Registry.
  - `container_registry_use_managed_identity` - (Optional) Should connections for Azure Container Registry use MSI.
  - `default_documents` - (Optional) Specifies a list of Default Documents.
  - `detailed_error_logging_enabled` - (Optional) Should detailed error logging be enabled?
  - `document_root` - (Optional) The document root path.
  - `elastic_instance_minimum` - (Optional) The number of minimum instances for Elastic Premium plans.
  - `elastic_web_app_scale_limit` - (Optional) The maximum number of workers for Elastic scale.
  - `ftps_state` - (Optional) State of FTP / FTPS service. Defaults to `FtpsOnly`.
  - `handler_mappings` - (Optional) A list of handler mappings (Windows IIS).
    - `arguments` - (Optional) The arguments to pass to the script processor.
    - `extension` - (Optional) The file extension to handle.
    - `script_processor` - (Optional) The path to the script processor executable.
  - `health_check_path` - (Optional) The path to be checked for health.
  - `http2_enabled` - (Optional) Enable HTTP2 protocol. Defaults to `false`.
  - `http_logging_enabled` - (Optional) Should HTTP logging be enabled?
  - `ip_restriction_default_action` - (Optional) Default action for IP restrictions. Defaults to `Allow`.
  - `limits` - (Optional) Resource limits.
    - `max_disk_size_in_mb` - (Optional) The maximum disk size in MB.
    - `max_memory_in_mb` - (Optional) The maximum memory in MB.
    - `max_percentage_cpu` - (Optional) The maximum CPU percentage.
  - `load_balancing_mode` - (Optional) The Site load balancing mode. Defaults to `LeastRequests`.
  - `logs_directory_size_limit` - (Optional) The HTTP log directory size limit in MB.
  - `managed_pipeline_mode` - (Optional) Managed pipeline mode. Defaults to `Integrated`.
  - `min_tls_cipher_suite` - (Optional) The minimum TLS cipher suite.
  - `minimum_tls_version` - (Optional) The minimum TLS version. Defaults to `1.3`.
  - `pre_warmed_instance_count` - (Optional) The number of pre-warmed instances.
  - `remote_debugging_enabled` - (Optional) Should Remote Debugging be enabled? Defaults to `false`.
  - `remote_debugging_version` - (Optional) The Remote Debugging Version.
  - `request_tracing_enabled` - (Optional) Should request tracing be enabled?
  - `request_tracing_expiration_time` - (Optional) The expiration time for request tracing.
  - `runtime_scale_monitoring_enabled` - (Optional) Should runtime scale monitoring be enabled?
  - `scm_ip_restriction_default_action` - (Optional) Default action for SCM IP restrictions. Defaults to `Allow`.
  - `scm_minimum_tls_version` - (Optional) SCM minimum TLS version. Defaults to `1.2`.
  - `scm_use_main_ip_restriction` - (Optional) Should SCM use the main IP restriction? Defaults to `false`.
  - `tracing_options` - (Optional) Azure tracing options.
  - `use_32_bit_worker` - (Optional) Use a 32-bit worker process. Defaults to `false`.
  - `vnet_private_ports_count` - (Optional) The number of private ports for VNet integration.
  - `vnet_route_all_enabled` - (Optional) Route all outbound traffic through VNet. Defaults to `false`.
  - `website_time_zone` - (Optional) The time zone for the website.
  - `websockets_enabled` - (Optional) Enable Web Sockets. Defaults to `false`.
  - `worker_count` - (Optional) The number of Workers.
  - `application_insights_connection_string` - (Optional) The connection string for Application Insights.
  - `application_insights_key` - (Optional) The instrumentation key for Application Insights.
  - `slot_application_insights_object_key` - (Optional) The key to the slot Application Insights object.
  - `application_stack` - (Optional) Application stack configuration.
    - `docker` - (Optional) Docker configuration with `docker_image_name`, `docker_registry_url`, and `docker_image_tag`.
    - `dotnet` - (Optional) .NET configuration with `dotnet_version`, `current_stack`, `use_custom_runtime`, and `use_dotnet_isolated_runtime`.
    - `java` - (Optional) Java configuration with `java_version`, `java_container`, and `java_container_version`.
    - `node` - (Optional) Node.js configuration with `node_version`.
    - `php` - (Optional) PHP configuration with `php_version`.
    - `python` - (Optional) Python configuration with `python_version`.
    - `powershell` - (Optional) PowerShell configuration with `powershell_version`.
- `lock` - (Optional) The lock to apply to the slot.
  - `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
  - `name` - (Optional) The name of the lock.
- `private_endpoints` - (Optional) Private endpoints for the slot.
  - `name` - (Optional) The name of the private endpoint.
  - `role_assignments` - (Optional) A map of role assignments for the private endpoint.
    - `role_definition_id_or_name` - (Required) The ID or name of the role definition.
    - `principal_id` - (Required) The ID of the principal.
    - `description` - (Optional) The description of the role assignment.
    - `skip_service_principal_aad_check` - (Optional) Skip the AAD check. Defaults to `false`.
    - `condition` - (Optional) The condition for the role assignment.
    - `condition_version` - (Optional) The condition version.
    - `delegated_managed_identity_resource_id` - (Optional) The delegated managed identity resource ID.
    - `principal_type` - (Optional) The type of the principal.
  - `lock` - (Optional) The lock for the private endpoint.
    - `kind` - (Required) The type of lock.
    - `name` - (Optional) The name of the lock.
  - `tags` - (Optional) Tags for the private endpoint.
  - `subnet_resource_id` - (Required) The resource ID of the subnet.
  - `private_dns_zone_group_name` - (Optional) The private DNS zone group name. Defaults to `default`.
  - `private_dns_zone_resource_ids` - (Optional) A set of private DNS zone resource IDs.
  - `application_security_group_associations` - (Optional) A map of application security group associations.
  - `private_service_connection_name` - (Optional) The private service connection name.
  - `network_interface_name` - (Optional) The network interface name.
  - `location` - (Optional) The Azure location.
  - `resource_group_name` - (Optional) The resource group name.
  - `ip_configurations` - (Optional) A map of IP configurations.
    - `name` - (Required) The name of the IP configuration.
    - `private_ip_address` - (Required) The private IP address.
- `role_assignments` - (Optional) Role assignments for the slot.
  - `role_definition_id_or_name` - (Required) The ID or name of the role definition.
  - `principal_id` - (Required) The ID of the principal.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) Skip the AAD check. Defaults to `false`.
  - `condition` - (Optional) The condition for the role assignment.
  - `condition_version` - (Optional) The condition version.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated managed identity resource ID.
  - `principal_type` - (Optional) The type of the principal.
- `storage_shares_to_mount` - (Optional) A map of storage shares to mount to the deployment slot.
  - `account_name` - (Required) The name of the Storage Account.
  - `mount_path` - (Required) The path to mount the share at.
  - `name` - (Required) The name of the storage mount.
  - `share_name` - (Required) The name of the file share.
  - `type` - (Optional) The type of storage. Defaults to `AzureFiles`.
- `connection_strings` - (Optional) A map of connection strings for the slot.
  - `name` - (Optional) The name of the connection string.
  - `type` - (Optional) The type of the connection string.
  - `value` - (Optional) The value of the connection string.
DESCRIPTION
  nullable    = false
}

variable "deployment_slots_inherit_lock" {
  type        = bool
  default     = true
  description = "Whether to inherit the lock from the parent resource for the deployment slots. Defaults to `true`."
}

variable "diagnostic_settings" {
  type = map(object({
    name = optional(string, null)
    logs = optional(set(object({
      category       = optional(string, null)
      category_group = optional(string, null)
      enabled        = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    metrics = optional(set(object({
      category = optional(string, null)
      enabled  = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of diagnostic settings to create on the App Service Environment (ASE). The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
  - `logs` - (Optional) A set of log configuration blocks.
    - `category` - (Optional) The log category.
    - `category_group` - (Optional) The log category group.
    - `enabled` - (Optional) Is the log enabled? Defaults to `true`.
    - `retention_policy` - (Optional) A retention policy block.
      - `days` - (Optional) The number of days to retain. Defaults to `0`.
      - `enabled` - (Optional) Is the retention policy enabled? Defaults to `false`.
  - `metrics` - (Optional) A set of metric configuration blocks.
    - `category` - (Optional) The metric category.
    - `enabled` - (Optional) Is the metric enabled? Defaults to `true`.
    - `retention_policy` - (Optional) A retention policy block.
      - `days` - (Optional) The number of days to retain. Defaults to `0`.
      - `enabled` - (Optional) Is the retention policy enabled? Defaults to `false`.
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
  - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
  - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
  - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
  - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
  - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.
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

variable "dns_configuration" {
  type = object({
    dns_alt_server            = optional(string)
    dns_max_cache_timeout     = optional(number)
    dns_retry_attempt_count   = optional(number)
    dns_retry_attempt_timeout = optional(number)
    dns_servers               = optional(list(string))
  })
  default     = null
  description = <<DESCRIPTION
(Optional) DNS configuration for the App Service.

- `dns_alt_server` - (Optional) Alternate DNS server to be used by the App Service.
- `dns_max_cache_timeout` - (Optional) Custom time for DNS to be cached in seconds.
- `dns_retry_attempt_count` - (Optional) Total number of retries for DNS lookup.
- `dns_retry_attempt_timeout` - (Optional) Timeout for a single DNS lookup in seconds.
- `dns_servers` - (Optional) List of custom DNS servers to be used by the App Service.
DESCRIPTION
}

variable "enable_application_insights" {
  type        = bool
  default     = true
  description = "Should Application Insights be enabled for the App Service? Defaults to `true`."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Is the App Service enabled? Defaults to `true`."
}

variable "end_to_end_encryption_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should end-to-end encryption be enabled between the App Service front ends and the workers?"
}

variable "fc1_runtime_name" {
  type        = string
  default     = null
  description = "The Runtime of the Flex Consumption Function App. Possible values are `node`, `dotnet-isolated`, `powershell`, `python`, `java`."
}

variable "fc1_runtime_version" {
  type        = string
  default     = null
  description = "The Runtime version of the Flex Consumption Function App."
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Should basic authentication be enabled for FTP publish? Defaults to `false`."
}

variable "function_app_uses_fc1" {
  type        = bool
  default     = false
  description = "Should this Function App run on a Flex Consumption Plan? Defaults to `false`."
}

variable "functions_extension_version" {
  type        = string
  default     = "~4"
  description = "The version of the Azure Functions runtime to use. Defaults to `~4`."
}

variable "host_names_disabled" {
  type        = bool
  default     = null
  description = "(Optional) Should the public hostnames of the app be disabled? When `true`, the app is only accessible via the API management process."
}

variable "hosting_environment_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of the App Service Environment to host this App Service in."
}

variable "https_only" {
  type        = bool
  default     = true
  description = "Should the App Service only be accessible over HTTPS? Defaults to `true`."
}

variable "hyper_v" {
  type        = bool
  default     = null
  description = "(Optional) Should the App Service run in Hyper-V isolation?"
}

variable "instance_memory_in_mb" {
  type        = number
  default     = 2048
  description = "The amount of memory to allocate for Flex Consumption instances. Defaults to `2048`."

  validation {
    error_message = "The value must be one of: `512`, `2048`, or `4096`"
    condition     = contains([512, 2048, 4096], var.instance_memory_in_mb)
  }
}

variable "ip_mode" {
  type        = string
  default     = null
  description = "(Optional) Specifies the IP mode of the app. Possible values are `IPv4`, `IPv4AndIPv6`, and `IPv6`."

  validation {
    error_message = "The value must be one of: `IPv4`, `IPv4AndIPv6`, or `IPv6`."
    condition     = var.ip_mode == null || can(index(["IPv4", "IPv4AndIPv6", "IPv6"], var.ip_mode))
  }
}

variable "key_vault_reference_identity" {
  type        = string
  default     = null
  description = "The identity to use for Key Vault references."
}

variable "kind" {
  type        = string
  default     = "webapp"
  description = <<DESCRIPTION
The type of App Service to deploy. This maps to the ARM API `kind` property.
Possible values are `functionapp`, `webapp` and `logicapp`. Defaults to `webapp`.
DESCRIPTION
  nullable    = false

  validation {
    error_message = "The value must be one of: `functionapp`, `webapp` or `logicapp`"
    condition     = contains(["functionapp", "webapp", "logicapp"], var.kind)
  }
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
The lock level to apply.

- `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: `CanNotDelete`, or `ReadOnly`."
  }
}

variable "logic_app_runtime_version" {
  type        = string
  default     = "~4"
  description = "The runtime version for the Logic App. Defaults to `~4`."
}

variable "logs" {
  type = map(object({
    application_logs = optional(map(object({
      azure_blob_storage = optional(object({
        level             = optional(string, "Off")
        retention_in_days = optional(number, 0)
        sas_url           = string
      }))
      file_system = optional(object({
        level = optional(string, "Off")
      }), {})
    })), {})
    detailed_error_messages = optional(bool, false)
    failed_requests_tracing = optional(bool, false)
    http_logs = optional(map(object({
      azure_blob_storage = optional(object({
        retention_in_days = optional(number, 0)
        sas_url           = string
      }))
      file_system = optional(object({
        retention_in_days = optional(number, 0)
        retention_in_mb   = number
      }))
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of logs configuration for the App Service.

- `application_logs` - (Optional) A map of application log settings.
  - `azure_blob_storage` - (Optional) Azure Blob Storage configuration for application logs.
    - `level` - (Optional) The log level. Defaults to `Off`.
    - `retention_in_days` - (Optional) The retention period in days. Defaults to `0`.
    - `sas_url` - (Required) The SAS URL to the Azure Blob Storage container.
  - `file_system` - (Optional) File system configuration for application logs.
    - `level` - (Optional) The file system log level. Defaults to `Off`.
- `detailed_error_messages` - (Optional) Should detailed error messages be enabled? Defaults to `false`.
- `failed_requests_tracing` - (Optional) Should failed request tracing be enabled? Defaults to `false`.
- `http_logs` - (Optional) A map of HTTP log settings.
  - `azure_blob_storage` - (Optional) Azure Blob Storage configuration for HTTP logs.
    - `retention_in_days` - (Optional) The retention period in days. Defaults to `0`.
    - `sas_url` - (Required) The SAS URL to the Azure Blob Storage container.
  - `file_system` - (Optional) File system configuration for HTTP logs.
    - `retention_in_days` - (Optional) The retention period in days. Defaults to `0`.
    - `retention_in_mb` - (Required) The maximum size in MB before being rotated.
DESCRIPTION
  nullable    = false
}

variable "managed_environment_id" {
  type        = string
  default     = null
  description = "(Optional) The Azure Resource Manager ID of the Azure Container Apps managed environment to host this App Service in."
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Managed identities to be created for the resource.

- `system_assigned` - (Optional) Should a system-assigned managed identity be created? Defaults to `false`.
- `user_assigned_resource_ids` - (Optional) A set of user-assigned managed identity resource IDs to assign. Defaults to `[]`.
DESCRIPTION
  nullable    = false
}

variable "maximum_instance_count" {
  type        = number
  default     = null
  description = "The number of workers this function app can scale out to."
}

variable "os_type" {
  type        = string
  default     = "Linux"
  description = "The operating system type. `Linux` sets `reserved = true` on the ARM resource. Defaults to `Linux`."
  nullable    = false

  validation {
    error_message = "The value must be one of: `Linux` or `Windows`"
    condition     = contains(["Linux", "Windows"], var.os_type)
  }
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
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint.
  - `role_definition_id_or_name` - (Required) The ID or name of the role definition.
  - `principal_id` - (Required) The ID of the principal.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) Skip the AAD check. Defaults to `false`.
  - `condition` - (Optional) The condition for the role assignment.
  - `condition_version` - (Optional) The condition version.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated managed identity resource ID.
  - `principal_type` - (Optional) The type of the principal.
- `lock` - (Optional) The lock level to apply to the private endpoint.
  - `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
  - `name` - (Optional) The name of the lock.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate.
- `application_security_group_associations` - (Optional) A map of resource IDs of application security groups.
- `private_service_connection_name` - (Optional) The name of the private service connection.
- `network_interface_name` - (Optional) The name of the network interface.
- `location` - (Optional) The Azure location. Defaults to the resource group location.
- `resource_group_name` - (Optional) The resource group. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations for the private endpoint.
  - `name` - (Required) The name of the IP configuration.
  - `private_ip_address` - (Required) The private IP address.
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
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally. Defaults to `true`."
  nullable    = false
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Should the App Service be accessible from the public network? Defaults to `false`."
}

variable "redundancy_mode" {
  type        = string
  default     = null
  description = "(Optional) The site redundancy mode. Possible values are `ActiveActive`, `Failover`, `GeoRedundant`, `Manual`, and `None`."

  validation {
    error_message = "The value must be one of: `ActiveActive`, `Failover`, `GeoRedundant`, `Manual`, or `None`."
    condition     = var.redundancy_mode == null || can(index(["ActiveActive", "Failover", "GeoRedundant", "Manual", "None"], var.redundancy_mode))
  }
}

variable "resource_config" {
  type = object({
    cpu    = optional(number)
    memory = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Function app resource requirements for Container App environment hosted apps.

- `cpu` - (Optional) The required number of CPU cores.
- `memory` - (Optional) The required memory size (e.g. `1.0Gi`).
DESCRIPTION
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
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are `2.0`.
- `delegated_managed_identity_resource_id` - The delegated Azure Resource Id which contains a Managed Identity.
- `principal_type` - The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`.
DESCRIPTION
  nullable    = false
}

variable "scm_publish_basic_authentication_enabled" {
  type        = bool
  default     = true
  description = "Should basic authentication be enabled for SCM publish? Defaults to `true`."
}

variable "scm_site_also_stopped" {
  type        = bool
  default     = null
  description = "(Optional) Should the SCM site also be stopped when the app is stopped? Defaults to `false`."
}

variable "site_config" {
  type = object({
    always_on             = optional(bool, true)
    api_definition_url    = optional(string)
    api_management_api_id = optional(string)
    app_command_line      = optional(string)
    app_scale_limit       = optional(number)
    auto_heal_enabled     = optional(bool)
    auto_heal_rules = optional(object({
      actions = optional(object({
        action_type = string
        custom_action = optional(object({
          exe        = string
          parameters = optional(string)
        }))
        min_process_execution_time = optional(string, "00:00:00")
      }))
      triggers = optional(object({
        private_bytes_in_kb = optional(number)
        requests = optional(object({
          count         = number
          time_interval = string
        }))
        slow_requests = optional(object({
          count         = number
          time_interval = string
          time_taken    = string
          path          = optional(string)
        }))
        slow_requests_with_path = optional(list(object({
          count         = number
          time_interval = string
          time_taken    = string
          path          = optional(string)
        })), [])
        status_codes = optional(list(object({
          count         = number
          time_interval = string
          status        = number
          path          = optional(string)
          sub_status    = optional(number)
          win32_status  = optional(number)
        })), [])
        status_codes_range = optional(list(object({
          count         = number
          time_interval = string
          status_codes  = string
          path          = optional(string)
        })), [])
      }))
    }))
    auto_swap_slot_name                           = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    default_documents                             = optional(list(string))
    detailed_error_logging_enabled                = optional(bool)
    document_root                                 = optional(string)
    dotnet_framework_version                      = optional(string, "v4.0")
    elastic_instance_minimum                      = optional(number)
    elastic_web_app_scale_limit                   = optional(number)
    experiments = optional(object({
      ramp_up_rules = optional(list(object({
        action_host_name             = optional(string)
        change_decision_callback_url = optional(string)
        change_interval_in_minutes   = optional(number)
        change_step                  = optional(number)
        max_reroute_percentage       = optional(number)
        min_reroute_percentage       = optional(number)
        name                         = optional(string)
        reroute_percentage           = optional(number)
      })), [])
    }))
    ftps_state = optional(string, "FtpsOnly")
    handler_mappings = optional(list(object({
      arguments        = optional(string)
      extension        = optional(string)
      script_processor = optional(string)
    })))
    health_check_path             = optional(string)
    http2_enabled                 = optional(bool, false)
    http20_proxy_flag             = optional(number)
    http_logging_enabled          = optional(bool)
    ip_restriction_default_action = optional(string, "Allow")
    java_container                = optional(string)
    java_container_version        = optional(string)
    java_version                  = optional(string)
    limits = optional(object({
      max_disk_size_in_mb = optional(number)
      max_memory_in_mb    = optional(number)
      max_percentage_cpu  = optional(number)
    }))
    linux_fx_version                       = optional(string)
    load_balancing_mode                    = optional(string, "LeastRequests")
    local_mysql_enabled                    = optional(bool, false)
    logs_directory_size_limit              = optional(number)
    managed_pipeline_mode                  = optional(string, "Integrated")
    min_tls_cipher_suite                   = optional(string)
    minimum_tls_version                    = optional(string, "1.3")
    node_version                           = optional(string)
    php_version                            = optional(string)
    powershell_version                     = optional(string)
    pre_warmed_instance_count              = optional(number)
    python_version                         = optional(string)
    remote_debugging_enabled               = optional(bool, false)
    remote_debugging_version               = optional(string)
    request_tracing_enabled                = optional(bool)
    request_tracing_expiration_time        = optional(string)
    runtime_scale_monitoring_enabled       = optional(bool)
    scm_ip_restriction_default_action      = optional(string, "Allow")
    scm_minimum_tls_version                = optional(string, "1.2")
    scm_type                               = optional(string, "None")
    scm_use_main_ip_restriction            = optional(bool, false)
    tracing_options                        = optional(string)
    use_32_bit_worker                      = optional(bool, false)
    vnet_private_ports_count               = optional(number)
    vnet_route_all_enabled                 = optional(bool, false)
    website_time_zone                      = optional(string)
    websockets_enabled                     = optional(bool, false)
    windows_fx_version                     = optional(string)
    worker_count                           = optional(number)
    application_insights_connection_string = optional(string)
    application_insights_key               = optional(string)
    cors = optional(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool, false)
    }))
    ip_restriction = optional(list(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string))
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      }))
    })), [])
    scm_ip_restriction = optional(list(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string))
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      }))
    })), [])
    application_stack = optional(object({
      docker = optional(object({
        docker_image_name   = optional(string)
        docker_registry_url = optional(string)
        docker_image_tag    = optional(string, "latest")
      }))
      dotnet = optional(object({
        dotnet_version              = optional(string)
        current_stack               = optional(string)
        use_custom_runtime          = optional(bool, false)
        use_dotnet_isolated_runtime = optional(bool, false)
      }))
      java = optional(object({
        java_version           = optional(string)
        java_container         = optional(string)
        java_container_version = optional(string)
      }))
      node = optional(object({
        node_version = optional(string)
      }))
      php = optional(object({
        php_version = optional(string)
      }))
      python = optional(object({
        python_version = optional(string)
      }))
      powershell = optional(object({
        powershell_version = optional(string)
      }))
    }))
    virtual_application = optional(list(object({
      physical_path   = optional(string, "site\\wwwroot")
      preload_enabled = optional(bool, false)
      virtual_path    = optional(string, "/")
      virtual_directory = optional(list(object({
        physical_path = optional(string)
        virtual_path  = optional(string)
      })), [])
    })), [])
  })
  default     = {}
  description = <<DESCRIPTION
An object that configures the App Service's site configuration. These map to the ARM API `siteConfig` properties.

- `always_on` - (Optional) If this App is Always On enabled. Defaults to `true`.
- `api_definition_url` - (Optional) The URL of the API definition.
- `api_management_api_id` - (Optional) The ID of the API Management API.
- `app_command_line` - (Optional) The App command line to launch.
- `app_scale_limit` - (Optional) The number of workers this function app can scale out to.
- `auto_heal_enabled` - (Optional) Should Auto Heal be enabled? Maps to `autoHealEnabled` in the API.
- `auto_heal_rules` - (Optional) Configures the Auto Heal rules for the App Service. Maps to `autoHealRules` in the API.
  - `actions` - (Optional) The action to take when the trigger is activated.
    - `action_type` - (Required) The type of action. Possible values are `Recycle`, `LogEvent`, and `CustomAction`.
    - `custom_action` - (Optional) A custom action block.
      - `exe` - (Required) The executable to run.
      - `parameters` - (Optional) The parameters to pass to the executable.
    - `min_process_execution_time` - (Optional) The minimum process execution time. Defaults to `00:00:00`.
  - `triggers` - (Optional) The trigger conditions for auto heal.
    - `private_bytes_in_kb` - (Optional) The amount of private memory in KB that triggers the action.
    - `requests` - (Optional) The request count trigger.
      - `count` - (Required) The number of requests within the interval.
      - `time_interval` - (Required) The time interval.
    - `slow_requests` - (Optional) The slow request trigger.
      - `count` - (Required) The number of slow requests within the interval.
      - `time_interval` - (Required) The time interval.
      - `time_taken` - (Required) The threshold for time taken.
      - `path` - (Optional) The request path to match.
    - `slow_requests_with_path` - (Optional) A list of slow request triggers with path matching.
      - `count` - (Required) The number of slow requests within the interval.
      - `time_interval` - (Required) The time interval.
      - `time_taken` - (Required) The threshold for time taken.
      - `path` - (Optional) The request path to match.
    - `status_codes` - (Optional) A list of status code-based triggers.
      - `count` - (Required) The number of occurrences within the interval.
      - `time_interval` - (Required) The time interval.
      - `status` - (Required) The status code.
      - `path` - (Optional) The request path to match.
      - `sub_status` - (Optional) The sub-status code.
      - `win32_status` - (Optional) The Win32 status code.
    - `status_codes_range` - (Optional) A list of status code range-based triggers.
      - `count` - (Required) The number of occurrences within the interval.
      - `time_interval` - (Required) The time interval.
      - `status_codes` - (Required) The status code range (e.g. `500-599`).
      - `path` - (Optional) The request path to match.
- `auto_swap_slot_name` - (Optional) The name of the slot to auto swap with.
- `container_registry_managed_identity_client_id` - (Optional) The Client ID of the MSI for Azure Container Registry.
- `container_registry_use_managed_identity` - (Optional) Should connections for Azure Container Registry use MSI.
- `default_documents` - (Optional) Specifies a list of Default Documents.
- `detailed_error_logging_enabled` - (Optional) Should detailed error logging be enabled?
- `document_root` - (Optional) The document root path.
- `dotnet_framework_version` - (Optional) The .NET Framework version. Defaults to `v4.0`.
- `elastic_instance_minimum` - (Optional) The number of minimum instances for Elastic Premium plans.
- `elastic_web_app_scale_limit` - (Optional) The maximum number of workers for Elastic scale.
- `experiments` - (Optional) Traffic routing experiments configuration.
  - `ramp_up_rules` - (Optional) A list of ramp-up rules for traffic routing.
    - `action_host_name` - (Optional) The hostname of the slot to route traffic to.
    - `change_decision_callback_url` - (Optional) URL to a custom decision algorithm.
    - `change_interval_in_minutes` - (Optional) Interval in minutes at which to re-evaluate routing percentage.
    - `change_step` - (Optional) The percentage to change the routing by at each interval.
    - `max_reroute_percentage` - (Optional) The maximum percentage of traffic to reroute.
    - `min_reroute_percentage` - (Optional) The minimum percentage of traffic to reroute.
    - `name` - (Optional) The name of the ramp-up rule (typically the slot name).
    - `reroute_percentage` - (Optional) The current percentage of traffic to reroute.
- `ftps_state` - (Optional) State of FTP / FTPS service. Possible values: `AllAllowed`, `FtpsOnly`, `Disabled`. Defaults to `FtpsOnly`.
- `handler_mappings` - (Optional) A list of handler mappings (Windows IIS).
  - `arguments` - (Optional) The arguments to pass to the script processor.
  - `extension` - (Optional) The file extension to handle.
  - `script_processor` - (Optional) The path to the script processor executable.
- `health_check_path` - (Optional) The path to be checked for health.
- `http2_enabled` - (Optional) Enable HTTP2 protocol. Defaults to `false`.
- `http20_proxy_flag` - (Optional) HTTP/2 proxy flag. `0` = disabled, `1` = pass through HTTP/2, `2` = gRPC only.
- `http_logging_enabled` - (Optional) Should HTTP logging be enabled?
- `ip_restriction_default_action` - (Optional) Default action for IP restrictions. Defaults to `Allow`.
- `limits` - (Optional) Resource limits for the App Service.
  - `max_disk_size_in_mb` - (Optional) The maximum disk size in MB.
  - `max_memory_in_mb` - (Optional) The maximum memory in MB.
  - `max_percentage_cpu` - (Optional) The maximum CPU percentage.
- `java_container` - (Optional) The Java container type (e.g. `TOMCAT`, `JETTY`). Direct alternative to `application_stack.java.java_container`.
- `java_container_version` - (Optional) The Java container version. Direct alternative to `application_stack.java.java_container_version`.
- `java_version` - (Optional) The Java version. Direct alternative to `application_stack.java.java_version`.
- `linux_fx_version` - (Optional) The Linux App Framework and version for the App Service. Direct value takes precedence over `application_stack` derived value.
- `load_balancing_mode` - (Optional) The Site load balancing mode. Defaults to `LeastRequests`.
- `local_mysql_enabled` - (Optional) Should Local MySQL be enabled? Defaults to `false`.
- `logs_directory_size_limit` - (Optional) The HTTP log directory size limit in MB.
- `managed_pipeline_mode` - (Optional) Managed pipeline mode. Defaults to `Integrated`.
- `min_tls_cipher_suite` - (Optional) The minimum TLS cipher suite. E.g. `TLS_AES_256_GCM_SHA384`.
- `minimum_tls_version` - (Optional) The minimum TLS version. Defaults to `1.3`.
- `node_version` - (Optional) The Node.js version. Direct alternative to `application_stack.node.node_version`.
- `php_version` - (Optional) The PHP version. Direct alternative to `application_stack.php.php_version`.
- `powershell_version` - (Optional) The PowerShell version. Direct alternative to `application_stack.powershell.powershell_version`.
- `pre_warmed_instance_count` - (Optional) The number of pre-warmed instances.
- `python_version` - (Optional) The Python version. Direct alternative to `application_stack.python.python_version`.
- `remote_debugging_enabled` - (Optional) Should Remote Debugging be enabled. Defaults to `false`.
- `remote_debugging_version` - (Optional) The Remote Debugging Version.
- `request_tracing_enabled` - (Optional) Should request tracing be enabled?
- `request_tracing_expiration_time` - (Optional) The expiration time for request tracing.
- `runtime_scale_monitoring_enabled` - (Optional) Should runtime scale monitoring be enabled?
- `scm_ip_restriction_default_action` - (Optional) Default action for SCM IP restrictions. Defaults to `Allow`.
- `scm_minimum_tls_version` - (Optional) SCM minimum TLS version. Defaults to `1.2`.
- `scm_type` - (Optional) The SCM type. Defaults to `None`.
- `scm_use_main_ip_restriction` - (Optional) Should SCM use the main IP restriction.
- `tracing_options` - (Optional) Azure tracing options.
- `use_32_bit_worker` - (Optional) Use a 32-bit worker process. Defaults to `false`.
- `vnet_private_ports_count` - (Optional) The number of private ports assigned to the app for VNet integration.
- `vnet_route_all_enabled` - (Optional) Route all outbound traffic through VNet. Defaults to `false`.
- `website_time_zone` - (Optional) The time zone for the website (e.g. `Eastern Standard Time`).
- `websockets_enabled` - (Optional) Enable Web Sockets. Defaults to `false`.
- `windows_fx_version` - (Optional) The Windows App Framework and version for the App Service. Direct value takes precedence over `application_stack` derived value.
- `worker_count` - (Optional) The number of Workers.
- `application_insights_connection_string` - (Optional) The connection string for Application Insights.
- `application_insights_key` - (Optional) The instrumentation key for Application Insights.
- `cors` - (Optional) CORS configuration.
  - `allowed_origins` - (Optional) A list of allowed origins.
  - `support_credentials` - (Optional) Should credentials be supported? Defaults to `false`.
- `ip_restriction` - (Optional) A list of IP restriction rules.
  - `action` - (Optional) The action. Defaults to `Allow`.
  - `ip_address` - (Optional) The CIDR notation IP address.
  - `name` - (Optional) The name of the rule.
  - `priority` - (Optional) The priority. Defaults to `65000`.
  - `service_tag` - (Optional) The service tag.
  - `virtual_network_subnet_id` - (Optional) The subnet resource ID.
  - `headers` - (Optional) Header-based restrictions.
    - `x_azure_fdid` - (Optional) A list of Azure Front Door IDs.
    - `x_fd_health_probe` - (Optional) A list of health probe values.
    - `x_forwarded_for` - (Optional) A list of forwarded-for addresses.
    - `x_forwarded_host` - (Optional) A list of forwarded hosts.
- `scm_ip_restriction` - (Optional) A list of SCM IP restriction rules.
  - `action` - (Optional) The action. Defaults to `Allow`.
  - `ip_address` - (Optional) The CIDR notation IP address.
  - `name` - (Optional) The name of the rule.
  - `priority` - (Optional) The priority. Defaults to `65000`.
  - `service_tag` - (Optional) The service tag.
  - `virtual_network_subnet_id` - (Optional) The subnet resource ID.
  - `headers` - (Optional) Header-based restrictions.
    - `x_azure_fdid` - (Optional) A list of Azure Front Door IDs.
    - `x_fd_health_probe` - (Optional) A list of health probe values.
    - `x_forwarded_for` - (Optional) A list of forwarded-for addresses.
    - `x_forwarded_host` - (Optional) A list of forwarded hosts.
- `application_stack` - (Optional) Application stack configuration.
  - `docker` - (Optional) Docker configuration.
    - `docker_image_name` - (Optional) The Docker image name.
    - `docker_registry_url` - (Optional) The Docker registry URL.
    - `docker_image_tag` - (Optional) The Docker image tag. Defaults to `latest`.
  - `dotnet` - (Optional) .NET configuration.
    - `dotnet_version` - (Optional) The .NET version.
    - `current_stack` - (Optional) The current stack.
    - `use_custom_runtime` - (Optional) Use a custom runtime? Defaults to `false`.
    - `use_dotnet_isolated_runtime` - (Optional) Use the isolated runtime? Defaults to `false`.
  - `java` - (Optional) Java configuration.
    - `java_version` - (Optional) The Java version.
    - `java_container` - (Optional) The Java container.
    - `java_container_version` - (Optional) The Java container version.
  - `node` - (Optional) Node.js configuration.
    - `node_version` - (Optional) The Node.js version.
  - `php` - (Optional) PHP configuration.
    - `php_version` - (Optional) The PHP version.
  - `python` - (Optional) Python configuration.
    - `python_version` - (Optional) The Python version.
  - `powershell` - (Optional) PowerShell configuration.
    - `powershell_version` - (Optional) The PowerShell version.
- `virtual_application` - (Optional) A list of virtual application configurations.
  - `physical_path` - (Optional) The physical path. Defaults to `site\\wwwroot`.
  - `preload_enabled` - (Optional) Should preloading be enabled? Defaults to `false`.
  - `virtual_path` - (Optional) The virtual path. Defaults to `/`.
  - `virtual_directory` - (Optional) A list of virtual directories.
    - `physical_path` - (Optional) The physical path.
    - `virtual_path` - (Optional) The virtual path.
DESCRIPTION
}

variable "slot_application_insights" {
  type = map(object({
    application_type                      = optional(string, "web")
    inherit_tags                          = optional(bool, false)
    location                              = optional(string)
    name                                  = optional(string)
    parent_id                             = optional(string)
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
  }))
  default     = {}
  description = <<DESCRIPTION
Configures the Application Insights instance(s) for the deployment slot(s).

- `application_type` - (Optional) The type of Application Insights. Defaults to `web`.
- `inherit_tags` - (Optional) Should Application Insights inherit tags from the parent? Defaults to `false`.
- `location` - (Optional) The location of the Application Insights.
- `name` - (Optional) The name of the Application Insights.
- `parent_id` - (Optional) The resource ID of the Resource Group for Application Insights. Defaults to `var.parent_id`.
- `tags` - (Optional) Tags to apply to the Application Insights resource.
- `workspace_resource_id` - (Optional) The Log Analytics Workspace resource ID.
- `daily_data_cap_in_gb` - (Optional) The daily data volume cap in GB.
- `daily_data_cap_notifications_disabled` - (Optional) Should notifications be disabled when the daily data cap is reached?
- `retention_in_days` - (Optional) The retention period in days. Defaults to `90`.
- `sampling_percentage` - (Optional) The percentage of telemetry items to sample. Defaults to `100`.
- `disable_ip_masking` - (Optional) Should IP masking be disabled? Defaults to `false`.
- `local_authentication_disabled` - (Optional) Should local authentication be disabled? Defaults to `false`.
- `internet_ingestion_enabled` - (Optional) Should internet ingestion be enabled? Defaults to `true`.
- `internet_query_enabled` - (Optional) Should internet query be enabled? Defaults to `true`.
- `force_customer_storage_for_profiler` - (Optional) Should customer storage be forced for the profiler? Defaults to `false`.
DESCRIPTION
}

variable "slot_sensitive_app_settings" {
  type        = map(map(string))
  default     = {}
  description = "A map of sensitive app settings to apply to the deployment slot(s). The key MUST be the same key as the slot key."
  nullable    = false
  sensitive   = true
}

variable "slots_storage_shares_to_mount_sensitive_values" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
A map of sensitive values (Storage Access Key) for the Storage Account SMB file shares to mount to the deployment slots.
The key is the supplied input to `var.deployment_slots.<slot_key>.storage_shares_to_mount`.
The value is the secret value (storage access key).
DESCRIPTION
  sensitive   = true
}

variable "ssh_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should SSH be enabled for the App Service?"
}

variable "sticky_settings" {
  type = map(object({
    app_setting_names       = optional(list(string))
    connection_string_names = optional(list(string))
  }))
  default     = {}
  description = <<DESCRIPTION
A map of sticky settings to assign to the App Service.

- `app_setting_names` - (Optional) A list of app setting names that should be sticky to the slot.
- `connection_string_names` - (Optional) A list of connection string names that should be sticky to the slot.
DESCRIPTION
}

variable "storage_account_access_key" {
  type        = string
  default     = null
  description = "The access key of the Storage Account for the Function App."
  sensitive   = true
}

variable "storage_account_name" {
  type        = string
  default     = null
  description = "The name of the Storage Account for the Function App."
}

variable "storage_account_required" {
  type        = bool
  default     = null
  description = "(Optional) Should a storage account be required for the Function App? When set, the storage account must be specified in the app settings."
}

variable "storage_account_share_name" {
  type        = string
  default     = null
  description = "The name of the storage account file share (Logic App)."
}

variable "storage_authentication_type" {
  type        = string
  default     = null
  description = "The authentication type for the backend storage account. Possible values are `StorageAccountConnectionString`, `SystemAssignedIdentity`, and `UserAssignedIdentity`."
}

variable "storage_container_endpoint" {
  type        = string
  default     = null
  description = "The backend storage container endpoint for Flex Consumption Function Apps."
}

variable "storage_container_type" {
  type        = string
  default     = null
  description = "The storage container type. The current supported type is `blobContainer`."
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
  default     = {}
  description = <<DESCRIPTION
A map of Storage Account file shares to mount to the App Service.

- `access_key` - (Required) The access key for the Storage Account.
- `account_name` - (Required) The name of the Storage Account.
- `mount_path` - (Required) The path to mount the share at within the App Service.
- `name` - (Required) The name of the storage mount.
- `share_name` - (Required) The name of the file share.
- `type` - (Optional) The type of storage. Defaults to `AzureFiles`.
DESCRIPTION
}

variable "storage_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "The ID of the User Assigned Managed Identity for storage."
}

variable "storage_uses_managed_identity" {
  type        = bool
  default     = false
  description = "Should the Storage Account use a Managed Identity? Defaults to `false`."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "The map of tags to be applied to the resource."
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
 - `create` - (Defaults to 30 minutes) Used when creating the App Service.
 - `delete` - (Defaults to 30 minutes) Used when deleting the App Service.
 - `read` - (Defaults to 5 minutes) Used when retrieving the App Service.
 - `update` - (Defaults to 30 minutes) Used when updating the App Service.
EOT
}

variable "use_extension_bundle" {
  type        = bool
  default     = true
  description = "Should the extension bundle be used? (Logic App) Defaults to `true`."
}

variable "virtual_network_backup_restore_enabled" {
  type        = bool
  default     = false
  description = "Should backup and restore operations over the linked virtual network be enabled? Defaults to `false`."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet to deploy the App Service in for regional VNet integration."
}

variable "vnet_application_traffic_enabled" {
  type        = bool
  default     = false
  description = "Should application traffic be routed over virtual network? Maps to `outboundVnetRouting.applicationTraffic`. Defaults to `false`."
}

variable "vnet_content_share_enabled" {
  type        = bool
  default     = false
  description = "Should the traffic for the content share be routed over virtual network? Defaults to `false`."
}

variable "vnet_image_pull_enabled" {
  type        = bool
  default     = false
  description = "Should the traffic for image pull be routed over virtual network? Defaults to `false`."
}

variable "vnet_route_all_traffic" {
  type        = bool
  default     = false
  description = "Should all outbound traffic be routed over virtual network? Maps to `outboundVnetRouting.allTraffic`. Defaults to `false`."
}

variable "workload_profile_name" {
  type        = string
  default     = null
  description = "(Optional) The workload profile name for apps hosted in a Container Apps environment."
}

variable "zip_deploy_file" {
  type        = string
  default     = null
  description = "The path to the zip file to deploy to the App Service."
}
