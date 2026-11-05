variable "attach_subnet" {
  type        = bool
  default     = true
  description = "Pass the subnet ID when true, and null when false."
}

variable "ignore_body_changes" {
  type = object({
    resources_resource_groups                         = optional(list(string), [])
    web_serverfarms                                   = optional(list(string), [])
    network_virtual_networks                          = optional(list(string), [])
    storage_storage_accounts                          = optional(list(string), [])
    storage_storage_accounts_blob_services_containers = optional(list(string), [])
    authorization_role_assignments                    = optional(list(string), [])
  })
  default     = {}
  description = "Body paths ignored on fixture-owned resource groups, plans, networks, storage, containers, and roles. Changes take effect after apply."
  nullable    = false
}

variable "location" {
  type        = string
  default     = "australiaeast"
  description = "Flex-capable region, matching the existing Flex Consumption example."
}

variable "resource_types" {
  type = object({
    resources_resource_groups                         = optional(string, "Microsoft.Resources/resourceGroups@2025-04-01")
    web_serverfarms                                   = optional(string, "Microsoft.Web/serverfarms@2025-03-01")
    network_virtual_networks                          = optional(string, "Microsoft.Network/virtualNetworks@2024-05-01")
    storage_storage_accounts                          = optional(string, "Microsoft.Storage/storageAccounts@2025-01-01")
    storage_storage_accounts_blob_services_containers = optional(string, "Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01")
    authorization_role_assignments                    = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
  })
  default     = {}
  description = "API versions for fixture-owned resource groups, plans, networks, storage, containers, and roles."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = "Optional AzAPI retries for fixture-owned resources."
}

variable "tags" {
  type        = map(string)
  default     = { SecurityControl = "Ignore", regression = "issue-422" }
  description = "Tags for fixture-owned resources."
  nullable    = false
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Optional operation timeouts for fixture-owned resources."
}
