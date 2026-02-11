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
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}
