variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}

variable "application_logs" {
  type = object({
    azure_blob_storage = optional(object({
      level             = optional(string, "Off")
      retention_in_days = optional(number, 0)
      sas_url           = string
    }))
    file_system = optional(object({
      level = optional(string, "Off")
    }), {})
  })
  default     = null
  description = <<DESCRIPTION
Application log settings.

- `azure_blob_storage` - (Optional) Azure Blob Storage configuration for application logs.
  - `level` - (Optional) The log level. Defaults to `Off`.
  - `retention_in_days` - (Optional) The retention period in days. Defaults to `0`.
  - `sas_url` - (Required) The SAS URL to the Azure Blob Storage container.
- `file_system` - (Optional) File system configuration for application logs.
  - `level` - (Optional) The file system log level. Defaults to `Off`.
DESCRIPTION
}

variable "detailed_error_messages" {
  type        = bool
  default     = false
  description = "Should detailed error messages be enabled? Defaults to `false`."
}

variable "failed_requests_tracing" {
  type        = bool
  default     = false
  description = "Should failed request tracing be enabled? Defaults to `false`."
}

variable "http_logs" {
  type = object({
    azure_blob_storage = optional(object({
      retention_in_days = optional(number, 0)
      sas_url           = string
    }))
    file_system = optional(object({
      retention_in_days = optional(number, 0)
      retention_in_mb   = number
    }))
  })
  default     = null
  description = <<DESCRIPTION
HTTP log settings.

- `azure_blob_storage` - (Optional) Azure Blob Storage configuration for HTTP logs.
  - `retention_in_days` - (Optional) The retention period in days. Defaults to `0`.
  - `sas_url` - (Required) The SAS URL to the Azure Blob Storage container.
- `file_system` - (Optional) File system configuration for HTTP logs.
  - `retention_in_days` - (Optional) The retention period in days. Defaults to `0`.
  - `retention_in_mb` - (Required) The maximum size in MB before being rotated.
DESCRIPTION
}

variable "ignore_body_changes" {
  type = object({
    web_sites_config = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths whose changes are ignored, keyed by AzAPI resource type. Paths use dot notation, and a change takes effect only after an apply.

The AzAPI provider exposes `ignore_body_changes` on `azapi_resource` only, and this module manages its resource with a type that does not accept the argument. The variable exists for interface consistency; setting a non-empty value fails the plan with an explicit error rather than being silently ignored.
- `web_sites_config` - Paths ignored on the logs configuration.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    web_sites_config = optional(string, "Microsoft.Web/sites/config@2025-03-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by this module.

- `web_sites_config` - Resource type and API version for the logs configuration.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["Cannot modify this site because another operation is in progress"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number)
  })
  default     = {}
  description = <<DESCRIPTION
Retry configuration for the AzAPI resources declared by this module. Defaults to retrying the conflict Azure returns while another operation on the site is in progress.

- `error_message_regex` - (Optional) A list of regular expressions matched against error messages. A match triggers a retry.
- `interval_seconds` - (Optional) The initial interval in seconds between retries.
- `max_interval_seconds` - (Optional) The maximum interval in seconds between retries.
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Per-operation timeouts applied to the AzAPI resources declared by this module. Defaults to `null`, which uses the provider defaults. Each value is a Go duration string such as `30m`.

- `create` - (Optional) Timeout for create operations.
- `delete` - (Optional) Timeout for delete operations.
- `read` - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
DESCRIPTION
}
