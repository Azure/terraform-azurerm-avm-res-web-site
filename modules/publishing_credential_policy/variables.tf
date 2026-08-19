variable "name" {
  type        = string
  description = "The name of the publishing credential policy. Must be `ftp` or `scm`."
  nullable    = false

  validation {
    error_message = "The name must be either `ftp` or `scm`."
    condition     = contains(["ftp", "scm"], var.name)
  }
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

variable "allow" {
  type        = bool
  default     = false
  description = "Should basic authentication be allowed for this publishing credential type? Defaults to `false`."
}

variable "is_slot" {
  type        = bool
  default     = false
  description = "Whether the parent resource is a deployment slot. Defaults to `false`."
}

variable "ignore_body_changes" {
  type = object({
    web_sites_basic_publishing_credentials_policies       = optional(list(string), [])
    web_sites_slots_basic_publishing_credentials_policies = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths whose changes are ignored, keyed by AzAPI resource type. Paths use dot notation, and a change takes effect only after an apply.

The AzAPI provider exposes `ignore_body_changes` on `azapi_resource` only, and this module manages its resource with a type that does not accept the argument. The variable exists for interface consistency; setting a non-empty value fails the plan with an explicit error rather than being silently ignored.
- `web_sites_basic_publishing_credentials_policies` - Paths ignored on the publishing credential policy on a site.
- `web_sites_slots_basic_publishing_credentials_policies` - Paths ignored on the publishing credential policy on a slot.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    web_sites_basic_publishing_credentials_policies       = optional(string, "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-03-01")
    web_sites_slots_basic_publishing_credentials_policies = optional(string, "Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2025-03-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by this module.

- `web_sites_basic_publishing_credentials_policies` - Resource type and API version for the publishing credential policy on a site.
- `web_sites_slots_basic_publishing_credentials_policies` - Resource type and API version for the publishing credential policy on a slot.
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
