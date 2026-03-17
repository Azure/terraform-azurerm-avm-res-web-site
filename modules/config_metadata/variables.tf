variable "metadata" {
  type        = map(string)
  description = "A map of key-value pairs for site metadata (e.g. CURRENT_STACK)."
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
