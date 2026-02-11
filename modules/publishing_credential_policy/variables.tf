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

variable "name" {
  type        = string
  description = "The name of the publishing credential policy. Must be `ftp` or `scm`."
  nullable    = false

  validation {
    error_message = "The name must be either `ftp` or `scm`."
    condition     = contains(["ftp", "scm"], var.name)
  }
}

variable "allow" {
  type        = bool
  default     = false
  description = "Should basic authentication be allowed for this publishing credential type? Defaults to `false`."
}
