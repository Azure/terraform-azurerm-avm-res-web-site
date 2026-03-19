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
