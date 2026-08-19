variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}

variable "backup_name" {
  type        = string
  default     = null
  description = "The name of the backup. If not set, a default name will be generated."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Is backup enabled? Defaults to `true`."
}

variable "ignore_body_changes" {
  type = object({
    web_sites_config = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths whose changes are ignored, keyed by AzAPI resource type. Paths use dot notation, and a change takes effect only after an apply.

The AzAPI provider exposes `ignore_body_changes` on `azapi_resource` only, and this module manages its resource with a type that does not accept the argument. The variable exists for interface consistency; setting a non-empty value fails the plan with an explicit error rather than being silently ignored.
- `web_sites_config` - Paths ignored on the backup configuration.
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

- `web_sites_config` - Resource type and API version for the backup configuration.
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

variable "schedule" {
  type = object({
    frequency_interval       = optional(number)
    frequency_unit           = optional(string)
    keep_at_least_one_backup = optional(bool)
    retention_period_days    = optional(number)
    start_time               = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
The backup schedule configuration.

- `frequency_interval` - (Optional) How often the backup should be executed.
- `frequency_unit` - (Optional) The unit of time for the backup frequency. Possible values are `Day` and `Hour`.
- `keep_at_least_one_backup` - (Optional) Should at least one backup always be kept?
- `retention_period_days` - (Optional) The number of days to retain backups.
- `start_time` - (Optional) The start time for the backup schedule.
DESCRIPTION
}

variable "storage_account_url" {
  type        = string
  default     = null
  description = "The SAS URL to the Storage Account container for backup."
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
