variable "os_type" {
  type        = string
  description = "The OS type. Must be `Linux` or `Windows`."
  nullable    = false
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identity configuration."
  nullable    = false
}

variable "site_config" {
  type        = any
  default     = {}
  description = "The site configuration object to transform. Uses `any` type as this is an internal helper; callers validate types."
}
