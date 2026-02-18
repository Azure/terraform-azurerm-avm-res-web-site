variable "kind" {
  type        = string
  description = "The ARM kind of the app (e.g. `app`, `app,linux`, `functionapp`, `functionapp,linux`)."
  nullable    = false
}

variable "location" {
  type        = string
  description = "The Azure region for the slot."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the deployment slot."
  nullable    = false
}

variable "os_type" {
  type        = string
  description = "The OS type of the app. Must be `Linux` or `Windows`."
  nullable    = false

  validation {
    error_message = "The value must be `Linux` or `Windows`."
    condition     = contains(["Linux", "Windows"], var.os_type)
  }
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}

variable "service_plan_resource_id" {
  type        = string
  description = "The default App Service Plan resource ID (used if `server_farm_id` is not set)."
  nullable    = false
}

# App settings and config
variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "App settings for the slot."
}

variable "application_insights_connection_string" {
  type        = string
  default     = null
  description = "The Application Insights connection string (pre-computed from the parent module)."
  sensitive   = true
}

variable "application_insights_key" {
  type        = string
  default     = null
  description = "The Application Insights instrumentation key (pre-computed from the parent module)."
  sensitive   = true
}

variable "auto_generated_domain_name_label_scope" {
  type        = string
  default     = null
  description = "The scope of the auto-generated domain name label."
}

# Slot-specific properties
variable "client_affinity_enabled" {
  type        = bool
  default     = false
  description = "Should client affinity be enabled? Defaults to `false`."
}

variable "client_affinity_partitioning_enabled" {
  type        = bool
  default     = null
  description = "Should client affinity partitioning (CHIPS) be enabled?"
}

variable "client_affinity_proxy_enabled" {
  type        = bool
  default     = null
  description = "Should client affinity proxy be enabled?"
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Should client certificates be enabled? Defaults to `false`."
}

variable "client_certificate_exclusion_paths" {
  type        = string
  default     = null
  description = "Paths to exclude from client certificate authentication."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "The client certificate mode. Defaults to `Required`."
}

variable "connection_strings" {
  type = map(object({
    name  = optional(string)
    type  = optional(string)
    value = optional(string)
  }))
  default     = {}
  description = "Connection strings for the slot."
}

variable "container_size" {
  type        = number
  default     = null
  description = "The size of the function container in MB."
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
  description = "Dapr configuration for the slot."
}

variable "dns_configuration" {
  type = object({
    alternate_private_dns_zone_id = optional(string)
    dns_legacy_sort_order         = optional(bool)
    dns_suffix                    = optional(string)
  })
  default     = null
  description = "DNS configuration for the slot."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Is the slot enabled? Defaults to `true`."
}

variable "end_to_end_encryption_enabled" {
  type        = bool
  default     = null
  description = "Should end-to-end encryption be enabled?"
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Should FTP basic authentication be enabled? Defaults to `false`."
}

variable "function_app_uses_fc1" {
  type        = bool
  default     = false
  description = "Whether the parent app uses Flex Consumption (FC1) plan."
}

variable "host_names_disabled" {
  type        = bool
  default     = null
  description = "Should public hostnames be disabled?"
}

variable "hosting_environment_id" {
  type        = string
  default     = null
  description = "The resource ID of the App Service Environment."
}

variable "https_only" {
  type        = bool
  default     = true
  description = "Should the slot only be accessible over HTTPS? Defaults to `true`."
}

variable "hyper_v" {
  type        = bool
  default     = null
  description = "Should the slot run in Hyper-V isolation?"
}

variable "ip_mode" {
  type        = string
  default     = null
  description = "The IP mode. Possible values: `IPv4`, `IPv4AndIPv6`, `IPv6`."
}

variable "is_function_app" {
  type        = bool
  default     = false
  description = "Whether the parent app is a function app."
}

variable "is_web_app" {
  type        = bool
  default     = true
  description = "Whether the parent app is a web app."
}

variable "key_vault_reference_identity" {
  type        = string
  default     = null
  description = "The identity to use for Key Vault references."
}

# AVM interface variables
variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "The lock to apply to the slot."
}

variable "managed_environment_id" {
  type        = string
  default     = null
  description = "The Azure Container Apps managed environment ID."
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
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
  description = "Private endpoints for the slot."
  nullable    = false
}

variable "private_endpoints_inherit_lock" {
  type        = bool
  default     = false
  description = "Whether private endpoints should inherit the lock from the slot."
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage DNS zone groups for private endpoints."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Should public network access be enabled? Defaults to `false`."
}

variable "redundancy_mode" {
  type        = string
  default     = null
  description = "The site redundancy mode."
}

variable "resource_config" {
  type = object({
    cpu    = optional(number)
    memory = optional(string)
  })
  default     = null
  description = "Resource config for Container App environment hosted apps."
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
  description = "Role assignments for the slot."
  nullable    = false
}

variable "scm_site_also_stopped" {
  type        = bool
  default     = null
  description = "Should the SCM site also be stopped?"
}

variable "sensitive_app_settings" {
  type        = map(string)
  default     = {}
  description = "Sensitive app settings to merge (e.g. from the parent module's `slot_sensitive_app_settings` variable)."
}

variable "server_farm_id" {
  type        = string
  default     = null
  description = "Optional override server farm resource ID for this slot."
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
  description = "Site configuration for the deployment slot."
}

variable "ssh_enabled" {
  type        = bool
  default     = null
  description = "Should SSH be enabled?"
}

variable "storage_account_required" {
  type        = bool
  default     = null
  description = "Should a storage account be required?"
}

variable "storage_shares_access_keys" {
  type        = map(string)
  default     = {}
  description = "A map of access keys for storage shares to mount, keyed by the storage share mount key (sensitive)."
  sensitive   = true
}

variable "storage_shares_to_mount" {
  type = map(object({
    account_name = string
    mount_path   = string
    name         = string
    share_name   = string
    type         = optional(string, "AzureFiles")
  }))
  default     = {}
  description = "Storage shares to mount on the slot."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags to apply to the slot."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "The subnet ID for VNet integration."
}

variable "vnet_application_traffic_enabled" {
  type        = bool
  default     = false
  description = "Should application traffic use VNet routing? Defaults to `false`."
}

variable "vnet_backup_restore_enabled" {
  type        = bool
  default     = false
  description = "Should backup/restore traffic use VNet routing? Defaults to `false`."
}

variable "vnet_content_share_enabled" {
  type        = bool
  default     = false
  description = "Should content share traffic use VNet routing? Defaults to `false`."
}

variable "vnet_image_pull_enabled" {
  type        = bool
  default     = false
  description = "Should image pull traffic use VNet routing? Defaults to `false`."
}

variable "vnet_route_all_traffic" {
  type        = bool
  default     = false
  description = "Should all outbound traffic use VNet routing? Defaults to `false`."
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Should WebDeploy basic authentication be enabled? Defaults to `false`."
}

variable "workload_profile_name" {
  type        = string
  default     = null
  description = "The workload profile name."
}
