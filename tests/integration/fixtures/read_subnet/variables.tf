variable "phase" {
  type        = string
  description = "Observation label, also forcing a new bounded settling delay."
}

variable "site_id" {
  type        = string
  description = "The test-created site to read or detach."

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Web/sites", var.site_id))
    error_message = "site_id must identify a Microsoft.Web/sites resource."
  }
}

variable "subnet_id" {
  type        = string
  description = "The expected integration subnet when attached."

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Network/virtualNetworks/subnets", var.subnet_id))
    error_message = "subnet_id must identify a subnet."
  }
}

variable "detach_external" {
  type        = bool
  default     = false
  description = "Simulate out-of-band removal with DeleteSwiftVirtualNetwork, not a site PUT."
}

variable "expect_detached" {
  type        = bool
  default     = null
  description = "Expected live state; null records the result without asserting attachment."
}

variable "managed_subnet_after_refresh" {
  type        = string
  default     = null
  description = "Optional refresh-only plan body value, recorded separately from the fresh GET."
}

variable "planned_subnet" {
  type        = string
  default     = null
  description = "Optional normal plan body value; this does not encode planned actions."
}

variable "resource_types" {
  type = object({
    web_sites = optional(string, "Microsoft.Web/sites@2025-03-01")
  })
  default     = {}
  description = "The site API version for both the GET and the optional detach action."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = "Optional AzAPI retries."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Optional AzAPI operation timeouts."
}
