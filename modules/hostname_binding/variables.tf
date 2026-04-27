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

variable "retry" {
  type = object({
    error_message_regex = list(string)
    interval_seconds    = optional(number, 10)
    max_retries         = optional(number, 3)
  })
  default = {
    error_message_regex = [
      "Cannot modify this site because another operation is in progress",
      # Domain ownership validation is asynchronous on Azure's side; the binding
      # call can race ahead of DNS / verification record propagation. Retry
      # while validation is still in flight.
      "A CNAME record pointing from .* was not found",
      "A TXT record pointing from asuid\\..* was not found",
      "Hostname .* does not resolve to the controller IP address",
      "Validation failed for a hostname",
    ]
  }
  description = "Retry configuration for azapi resources. By default, retries on transient site lock errors and on the DNS / hostname validation errors that surface while custom domain ownership records are still propagating."
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
