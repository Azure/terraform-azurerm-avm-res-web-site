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

variable "retry" {
  type = object({
    error_message_regex = list(string)
    interval_seconds    = optional(number, 10)
    max_retries         = optional(number, 3)
  })
  default     = null
  description = "(Optional) Retry configuration for the underlying azapi resource."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags applied to the certificate resource."
}
