variable "location" {
  type        = string
  description = "The Azure region where the certificate resource will be created. Should match the App Service Plan."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the App Service certificate."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the parent resource group."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure resource group resource ID."
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._()-]+$", var.parent_id))
  }
}

variable "server_farm_id" {
  type        = string
  description = "The resource ID of the App Service Plan that will host sites using this certificate. Required by Azure when sourcing the certificate from Key Vault."
  nullable    = false
}

variable "host_names" {
  type        = list(string)
  default     = null
  description = "(Optional) The host names the certificate applies to. If omitted, Azure derives them from the certificate's subject alternative names."
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
(Optional) The resource ID of the Key Vault that contains the certificate.

Either both `key_vault_id` and `key_vault_secret_name` must be supplied to
source the certificate from Key Vault, or `pfx_blob` (and optionally
`password`) must be supplied to upload an inline PFX. The two modes are
mutually exclusive.
DESCRIPTION
}

variable "key_vault_secret_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Key Vault secret/certificate that contains the PFX. Required when `key_vault_id` is set."
}

variable "password" {
  type        = string
  default     = null
  description = "(Optional) The password protecting the PFX supplied via `pfx_blob`."
  sensitive   = true
}

variable "pfx_blob" {
  type        = string
  default     = null
  description = "(Optional) The base64-encoded contents of the PFX file. Mutually exclusive with `key_vault_id`."
  sensitive   = true
}

variable "ignore_body_changes" {
  type = object({
    web_certificates = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths whose changes are ignored, keyed by AzAPI resource type. Paths use dot notation, and a change takes effect only after an apply.

- `web_certificates` - Paths ignored on the certificate.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    web_certificates = optional(string, "Microsoft.Web/certificates@2025-03-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by this module.

- `web_certificates` - Resource type and API version for the certificate.
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

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags applied to the certificate resource."
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
