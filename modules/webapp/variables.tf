variable "app_name" {
  description = "Name of the Azure Web App."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Web App."
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create the resource group or use an existing one."
  type        = bool
  default     = false
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "West Europe"
}

variable "os_type" {
  description = "The OS type for the App Service Plan and Web App. Can be 'Linux' or 'Windows'."
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either 'Linux' or 'Windows'."
  }
}

variable "sku_name" {
  description = "The SKU for the App Service Plan (e.g., P1v2, P2v3, S1)."
  type        = string
  default     = "P1v2"
}

variable "app_settings" {
  description = "A map of key-value pairs for App Settings. Note: Terraform will ignore subsequent changes to this map due to lifecycle block."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the resources."
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
