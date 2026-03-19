variable "connection_strings" {
  type = map(object({
    name  = optional(string)
    type  = optional(string)
    value = optional(string)
  }))
  description = <<DESCRIPTION
A map of connection strings to assign to the App Service.

- `name` - (Optional) The name of the connection string. If not set, the map key is used.
- `type` - (Optional) The type of the connection string.
- `value` - (Optional) The value of the connection string.
DESCRIPTION
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site or slot."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site or slot resource ID."
    condition = can(regex(
      "^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+(/slots/[a-zA-Z0-9._-]+)?$",
      var.parent_id
    ))
  }
}

variable "is_slot" {
  type        = bool
  default     = false
  description = "Whether the parent resource is a deployment slot. Defaults to `false`."
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
