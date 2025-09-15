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
}
