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

variable "additional_app_settings" {
  type        = map(string)
  default     = {}
  description = "Additional app settings to merge (e.g. from the parent module's `slot_app_settings` variable)."
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

# Slot-specific properties
variable "client_affinity_enabled" {
  type        = bool
  default     = false
  description = "Should client affinity be enabled? Defaults to `false`."
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

variable "enable_application_insights" {
  type        = bool
  default     = false
  description = "Whether application insights is enabled on the parent site."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Is the slot enabled? Defaults to `true`."
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Should FTP basic authentication be enabled? Defaults to `false`."
}

variable "https_only" {
  type        = bool
  default     = true
  description = "Should the slot only be accessible over HTTPS? Defaults to `true`."
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

variable "server_farm_id" {
  type        = string
  default     = null
  description = "Optional override server farm resource ID for this slot."
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
  })
  default     = {}
  description = "Site configuration for the deployment slot."
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

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Should WebDeploy basic authentication be enabled? Defaults to `false`."
}
