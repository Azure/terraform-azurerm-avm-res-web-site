variable "hostname" {
  type        = string
  description = "The hostname to bind to the site."
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

variable "ssl_state" {
  type        = string
  default     = null
  description = "The SSL state for the hostname binding. Possible values include `Disabled`, `IpBasedEnabled`, `SniEnabled`."
}

variable "thumbprint" {
  type        = string
  default     = null
  description = "The certificate thumbprint associated with the hostname."
}
