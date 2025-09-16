variable "function_app_slot_hybrid_connections" {
  type = map(object({
    name            = string
    function_app_id = string
    relay_id        = string
    hostname        = string
    port            = number
    send_key_name   = optional(string, "RootManageSharedAccessKey")
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of hybrid connection configurations for Function App slots.
  
  - `name` - (Required) The name of the hybrid connection. Changing this forces a new resource to be created.
  - `function_app_id` - (Required) The ID of the function app slot. Changing this forces a new resource to be created.
  - `relay_id` - (Required) The ID of the Azure Relay hybrid connection to use. Changing this forces a new resource to be created.
  - `hostname` - (Required) The hostname of the endpoint.
  - `port` - (Required) The port to use for the endpoint.
  - `send_key_name` - (Optional) The name of the Relay key with Send permission to use. Defaults to 'RootManageSharedAccessKey'.

  DESCRIPTION

  validation {
    condition = alltrue([
      for config in var.function_app_slot_hybrid_connections : can(regex("^[0-9a-zA-Z-]{1,60}$", config.name))
    ])
    error_message = "Hybrid connection name may only contain alphanumeric characters and dashes and up to 60 characters in length."
  }

  validation {
    condition = alltrue([
      for config in var.function_app_slot_hybrid_connections : length(trimspace(config.hostname)) > 0
    ])
    error_message = "The hostname cannot be empty or contain only whitespace characters."
  }

  validation {
    condition = alltrue([
      for config in var.function_app_slot_hybrid_connections : length(trimspace(config.send_key_name)) > 0
    ])
    error_message = "The send_key_name cannot be empty or contain only whitespace characters."
  }

  validation {
    condition = alltrue([
      for config in var.function_app_slot_hybrid_connections : config.port >= 1 && config.port <= 65535
    ])
    error_message = "Port must be a valid port number between 1 and 65535."
  }
}

variable "web_app_slot_hybrid_connections" {
  type = map(object({
    name          = string
    web_app_id    = string
    relay_id      = string
    hostname      = string
    port          = number
    send_key_name = optional(string, "RootManageSharedAccessKey")
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of hybrid connection configurations for Web App slots.
  
  - `name` - (Required) The name of the hybrid connection. Changing this forces a new resource to be created.
  - `web_app_id` - (Required) The ID of the web app slot. Changing this forces a new resource to be created.
  - `relay_id` - (Required) The ID of the Azure Relay hybrid connection to use. Changing this forces a new resource to be created.
  - `hostname` - (Required) The hostname of the endpoint.
  - `port` - (Required) The port to use for the endpoint.
  - `send_key_name` - (Optional) The name of the Relay key with Send permission to use. Defaults to 'RootManageSharedAccessKey'.

  DESCRIPTION

  validation {
    condition = alltrue([
      for config in var.web_app_slot_hybrid_connections : can(regex("^[0-9a-zA-Z-]{1,60}$", config.name))
    ])
    error_message = "Hybrid connection name may only contain alphanumeric characters and dashes and up to 60 characters in length."
  }

  validation {
    condition = alltrue([
      for config in var.web_app_slot_hybrid_connections : length(trimspace(config.hostname)) > 0
    ])
    error_message = "The hostname cannot be empty or contain only whitespace characters."
  }

  validation {
    condition = alltrue([
      for config in var.web_app_slot_hybrid_connections : length(trimspace(config.send_key_name)) > 0
    ])
    error_message = "The send_key_name cannot be empty or contain only whitespace characters."
  }

  validation {
    condition = alltrue([
      for config in var.web_app_slot_hybrid_connections : config.port >= 1 && config.port <= 65535
    ])
    error_message = "Port must be a valid port number between 1 and 65535."
  }
}
