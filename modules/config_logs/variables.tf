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
