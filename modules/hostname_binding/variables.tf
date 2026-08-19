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

variable "ignore_body_changes" {
  type = object({
    web_sites_host_name_bindings       = optional(list(string), [])
    web_sites_slots_host_name_bindings = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths whose changes are ignored, keyed by AzAPI resource type. Paths use dot notation, and a change takes effect only after an apply.

- `web_sites_host_name_bindings` - Paths ignored on the hostname binding on a site.
- `web_sites_slots_host_name_bindings` - Paths ignored on the hostname binding on a slot.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    web_sites_host_name_bindings       = optional(string, "Microsoft.Web/sites/hostNameBindings@2025-03-01")
    web_sites_slots_host_name_bindings = optional(string, "Microsoft.Web/sites/slots/hostNameBindings@2025-03-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by this module.

- `web_sites_host_name_bindings` - Resource type and API version for the hostname binding on a site.
- `web_sites_slots_host_name_bindings` - Resource type and API version for the hostname binding on a slot.
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
