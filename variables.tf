# Required Inputs

# Optional Inputs - Core properties

# Function App specific

# Logic App specific

# Web App / Function App publishing

# Networking

# Site Configuration

# App Settings

# Connection Strings

# Application Insights

# Auth Settings - kept for backward compatibility, will be mapped to sites/config authsettingsV2

# Auto Heal

# Backup

# Sticky Settings

# Logs

# Storage Mounts

# Custom Domains

# Timeouts

# AVM Standard Interfaces

# Deployment Slots

variable "kind" {
  type        = string
  description = <<DESCRIPTION
The type of App Service to deploy. This maps to the ARM API `kind` property.
Possible values are `functionapp`, `webapp` and `logicapp`.
DESCRIPTION

  validation {
    error_message = "The value must be one of: `functionapp`, `webapp` or `logicapp`"
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
  description = "The name which should be used for the App Service."
}

variable "os_type" {
  type        = string
  description = "The operating system type. `Linux` sets `reserved = true` on the ARM resource."

  validation {
    error_message = "The value must be one of: `Linux` or `Windows`"
    condition     = contains(["Linux", "Windows"], var.os_type)
  }
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the Resource Group where the App Service will be deployed."
}

variable "service_plan_resource_id" {
  type        = string
  description = "The resource ID of the App Service Plan to deploy the App Service in."
}

variable "all_child_resources_inherit_lock" {
  type        = bool
  default     = true
  description = "Should child resources inherit the lock from the parent resource? Defaults to `true`."
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
- `resource_group_name` - The Resource Group for Application Insights.
- `workspace_resource_id` - The Log Analytics Workspace resource ID.
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
  default     = {}
  description = "A map of authentication settings to assign to the App Service."
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
      cookie_expiration_time            = optional(string, "08:00:00")
      logout_endpoint                   = optional(string)
      nonce_expiration_time             = optional(string, "00:05:00")
      preserve_url_fragments_for_logins = optional(bool, false)
      token_refresh_extension_time      = optional(number, 72)
      token_store_enabled               = optional(bool, false)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      validate_nonce                    = optional(bool, true)
    })), {})
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
  default     = {}
  description = "A map of authentication settings (V2) to assign to the App Service."
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
  default     = {}
  description = "Configures the Auto Heal settings for the App Service."
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
  default     = {}
  description = "A map of backup settings for the App Service."
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
  description = "Should client affinity be enabled for the App Service?"
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Should client certificate be enabled for the App Service?"
}

variable "client_certificate_exclusion_paths" {
  type        = string
  default     = null
  description = "The client certificate exclusion paths for the App Service."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "The client certificate mode for the App Service. Possible values are `Required`, `Optional`, and `OptionalInteractiveUser`."
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
  default     = {}
  description = "A map of custom domains to assign to the App Service."
}

variable "daily_memory_time_quota" {
  type        = number
  default     = 0
  description = "(Optional) The amount of memory in gigabyte-seconds that your application is allowed to consume per day. Setting this value only affects Function Apps under the consumption plan. Defaults to `0`."
}

variable "deployment_slots" {
  type = map(object({
    name                          = optional(string)
    enabled                       = optional(bool, true)
    https_only                    = optional(bool, false)
    public_network_access_enabled = optional(bool, true)
    service_plan_id               = optional(string, null)
    tags                          = optional(map(string))
    virtual_network_subnet_id     = optional(string, null)
    app_settings                  = optional(map(string), {})
    site_config = optional(object({
      always_on                                     = optional(bool, true)
      api_definition_url                            = optional(string)
      api_management_api_id                         = optional(string)
      app_command_line                              = optional(string)
      app_scale_limit                               = optional(number)
      auto_swap_slot_name                           = optional(string)
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
      managed_pipeline_mode                         = optional(string, "Integrated")
      minimum_tls_version                           = optional(string, "1.3")
      pre_warmed_instance_count                     = optional(number)
      remote_debugging_enabled                      = optional(bool, false)
      remote_debugging_version                      = optional(string)
      runtime_scale_monitoring_enabled              = optional(bool)
      scm_ip_restriction_default_action             = optional(string, "Allow")
      scm_minimum_tls_version                       = optional(string, "1.2")
      scm_use_main_ip_restriction                   = optional(bool, false)
      use_32_bit_worker                             = optional(bool, false)
      vnet_route_all_enabled                        = optional(bool, false)
      websockets_enabled                            = optional(bool, false)
      worker_count                                  = optional(number)
      application_insights_connection_string        = optional(string)
      application_insights_key                      = optional(string)
      slot_application_insights_object_key          = optional(string)
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
  }))
  default     = {}
  description = <<DESCRIPTION
A map of deployment slots to create for the App Service.

- `name` - (Optional) The name of the slot.
- `enabled` - (Optional) Is the slot enabled? Defaults to `true`.
- `https_only` - (Optional) Should the slot only be accessible over HTTPS?
- `public_network_access_enabled` - (Optional) Should public network access be enabled?
- `service_plan_id` - (Optional) The App Service Plan ID to use for the slot.
- `tags` - (Optional) Tags to apply to the slot.
- `virtual_network_subnet_id` - (Optional) The subnet ID for VNet integration.
- `app_settings` - (Optional) App settings for the slot.
- `site_config` - (Optional) Site configuration for the slot.
- `lock` - (Optional) The lock to apply to the slot.
- `private_endpoints` - (Optional) Private endpoints for the slot.
- `role_assignments` - (Optional) Role assignments for the slot.
DESCRIPTION
  nullable    = false
}

variable "deployment_slots_inherit_lock" {
  type        = bool
  default     = true
  description = "Whether to inherit the lock from the parent resource for the deployment slots."
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
A map of diagnostic settings to create on the resource.

- `name` - (Optional) The name of the diagnostic setting.
- `log_categories` - (Optional) A set of log categories to send. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace.
- `storage_account_resource_id` - (Optional) The resource ID of the Storage Account.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule.
- `event_hub_name` - (Optional) The name of the event hub.
- `marketplace_partner_resource_id` - (Optional) The resource ID of the Marketplace resource.
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
  description = "Should Application Insights be enabled for the App Service?"
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
  description = "Should the App Service only be accessible over HTTPS?"
}

variable "instance_memory_in_mb" {
  type        = number
  default     = 2048
  description = "The amount of memory to allocate for Flex Consumption instances."

  validation {
    error_message = "The value must be one of: `512`, `2048`, or `4096`"
    condition     = contains([512, 2048, 4096], var.instance_memory_in_mb)
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
  description = "The lock level to apply. Possible values for `kind` are `CanNotDelete` and `ReadOnly`."

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
      file_system_level = optional(string, "Off")
    })), {})
    detailed_error_messages = optional(bool, false)
    failed_request_tracing  = optional(bool, false)
    http_logs = optional(map(object({
      azure_blob_storage_http = optional(object({
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
  description = "A map of logs configuration for the App Service."
  nullable    = false
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
    subresource_name                        = optional(string, "sites")
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
- `lock` - (Optional) The lock level to apply to the private endpoint.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - (Optional) The subresource name for the private endpoint. Defaults to `sites`.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate.
- `application_security_group_associations` - (Optional) A map of resource IDs of application security groups.
- `private_service_connection_name` - (Optional) The name of the private service connection.
- `network_interface_name` - (Optional) The name of the network interface.
- `location` - (Optional) The Azure location. Defaults to the resource group location.
- `resource_group_name` - (Optional) The resource group. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations for the private endpoint.
DESCRIPTION
  nullable    = false
}

variable "private_endpoints_inherit_lock" {
  type        = bool
  default     = true
  description = "Should the private endpoints inherit the lock from the parent resource?"
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally."
  nullable    = false
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Should the App Service be accessible from the public network? Defaults to `true`."
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
  description = "Should basic authentication be enabled for SCM publish?"
}

variable "site_config" {
  type = object({
    always_on                                     = optional(bool, true)
    api_definition_url                            = optional(string)
    api_management_api_id                         = optional(string)
    app_command_line                              = optional(string)
    app_scale_limit                               = optional(number)
    auto_swap_slot_name                           = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    default_documents                             = optional(list(string))
    dotnet_framework_version                      = optional(string, "v4.0")
    elastic_instance_minimum                      = optional(number)
    ftps_state                                    = optional(string, "FtpsOnly")
    health_check_eviction_time_in_min             = optional(number)
    health_check_path                             = optional(string)
    http2_enabled                                 = optional(bool, false)
    ip_restriction_default_action                 = optional(string, "Allow")
    linux_fx_version                              = optional(string)
    load_balancing_mode                           = optional(string, "LeastRequests")
    local_mysql_enabled                           = optional(bool, false)
    managed_pipeline_mode                         = optional(string, "Integrated")
    minimum_tls_version                           = optional(string, "1.3")
    pre_warmed_instance_count                     = optional(number)
    remote_debugging_enabled                      = optional(bool, false)
    remote_debugging_version                      = optional(string)
    runtime_scale_monitoring_enabled              = optional(bool)
    scm_ip_restriction_default_action             = optional(string, "Allow")
    scm_minimum_tls_version                       = optional(string, "1.2")
    scm_type                                      = optional(string, "None")
    scm_use_main_ip_restriction                   = optional(bool, false)
    use_32_bit_worker                             = optional(bool, false)
    vnet_route_all_enabled                        = optional(bool, false)
    websockets_enabled                            = optional(bool, false)
    worker_count                                  = optional(number)
    application_insights_connection_string        = optional(string)
    application_insights_key                      = optional(string)
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
- `container_registry_managed_identity_client_id` - (Optional) The Client ID of the MSI for Azure Container Registry.
- `container_registry_use_managed_identity` - (Optional) Should connections for Azure Container Registry use MSI.
- `default_documents` - (Optional) Specifies a list of Default Documents.
- `elastic_instance_minimum` - (Optional) The number of minimum instances for Elastic Premium plans.
- `ftps_state` - (Optional) State of FTP / FTPS service. Possible values: `AllAllowed`, `FtpsOnly`, `Disabled`. Defaults to `FtpsOnly`.
- `health_check_eviction_time_in_min` - (Optional) Time in minutes before unhealthy node is removed. Between `2` and `10`.
- `health_check_path` - (Optional) The path to be checked for health.
- `http2_enabled` - (Optional) Enable HTTP2 protocol. Defaults to `false`.
- `ip_restriction_default_action` - (Optional) Default action for IP restrictions. Defaults to `Allow`.
- `load_balancing_mode` - (Optional) The Site load balancing mode. Defaults to `LeastRequests`.
- `managed_pipeline_mode` - (Optional) Managed pipeline mode. Defaults to `Integrated`.
- `minimum_tls_version` - (Optional) The minimum TLS version. Defaults to `1.3`.
- `remote_debugging_enabled` - (Optional) Should Remote Debugging be enabled. Defaults to `false`.
- `remote_debugging_version` - (Optional) The Remote Debugging Version.
- `scm_minimum_tls_version` - (Optional) SCM minimum TLS version. Defaults to `1.2`.
- `scm_use_main_ip_restriction` - (Optional) Should SCM use the main IP restriction.
- `use_32_bit_worker` - (Optional) Use a 32-bit worker process. Defaults to `false`.
- `vnet_route_all_enabled` - (Optional) Route all outbound traffic through VNet. Defaults to `false`.
- `websockets_enabled` - (Optional) Enable Web Sockets. Defaults to `false`.
- `worker_count` - (Optional) The number of Workers.
- `cors` - (Optional) CORS configuration with `allowed_origins` and `support_credentials`.
- `ip_restriction` - (Optional) A list of IP restriction rules.
- `scm_ip_restriction` - (Optional) A list of SCM IP restriction rules.
- `application_stack` - (Optional) Application stack configuration. Supports `docker`, `dotnet`, `java`, `node`, `php`, `python`, and `powershell` sub-objects.
- `virtual_application` - (Optional) A list of virtual application configurations.
DESCRIPTION
}

variable "slot_app_settings" {
  type        = map(map(string))
  default     = {}
  description = "A map of app settings to apply to the deployment slot(s). The key MUST be the same key as the slot key."
  nullable    = false
  sensitive   = true
}

variable "slot_application_insights" {
  type = map(object({
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
  }))
  default     = {}
  description = "Configures the Application Insights instance(s) for the deployment slot(s)."
}

variable "slots_storage_shares_to_mount_sensitive_values" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
A map of sensitive values (Storage Access Key) for the Storage Account SMB file shares to mount to the Function App.
The key is the supplied input to `var.storage_shares_to_mount`.
The value is the secret value (storage access key).
DESCRIPTION
  sensitive   = true
}

variable "sticky_settings" {
  type = map(object({
    app_setting_names       = optional(list(string))
    connection_string_names = optional(list(string))
  }))
  default     = {}
  description = "A map of sticky settings to assign to the App Service."
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
  default     = {}
  description = "A map of Storage Account file shares to mount to the App Service."
}

variable "storage_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "The ID of the User Assigned Managed Identity for storage."
}

variable "storage_uses_managed_identity" {
  type        = bool
  default     = false
  description = "Should the Storage Account use a Managed Identity?"
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
  description = "Should the extension bundle be used? (Logic App)"
}

variable "virtual_network_backup_restore_enabled" {
  type        = bool
  default     = false
  description = "Should backup and restore operations over the linked virtual network be enabled?"
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet to deploy the App Service in for regional VNet integration."
}

variable "vnet_content_share_enabled" {
  type        = bool
  default     = false
  description = "Should the traffic for the content share be routed over virtual network?"
}

variable "vnet_image_pull_enabled" {
  type        = bool
  default     = false
  description = "Should the traffic for image pull be routed over virtual network?"
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = true
  description = "Should basic authentication be enabled for web deploy?"
}

variable "zip_deploy_file" {
  type        = string
  default     = null
  description = "The path to the zip file to deploy to the App Service."
}
