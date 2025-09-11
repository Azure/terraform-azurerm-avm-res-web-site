variable "function_app_slot_hybrid_connections" {
  type = map(object({
    slot_key      = string
    relay_id      = string
    hostname      = string
    port          = number
    send_key_name = optional(string, "RootManageSharedAccessKey")
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of hybrid connection configurations for Function App slots.
  
  - `slot_key` - The key of the deployment slot to configure the hybrid connection for.
  - `relay_id` - The ID of the Azure Relay hybrid connection to use.
  - `hostname` - The hostname of the endpoint.
  - `port` - The port to use for the endpoint.
  - `send_key_name` - (Optional) The name of the Relay key with Send permission to use. Defaults to 'RootManageSharedAccessKey'.

  Example:
  ```terraform
  function_app_slot_hybrid_connections = {
    staging_hybrid_conn = {
      slot_key      = "staging"
      relay_id      = "/subscriptions/.../hybridConnections/my-hybrid-connection"
      hostname      = "on-premises-server.local"
      port          = 1433
      send_key_name = "RootManageSharedAccessKey"
    }
  }
  ```
  DESCRIPTION
}

variable "web_app_slot_hybrid_connections" {
  type = map(object({
    slot_key      = string
    relay_id      = string
    hostname      = string
    port          = number
    send_key_name = optional(string, "RootManageSharedAccessKey")
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of hybrid connection configurations for Web App slots.
  
  - `slot_key` - The key of the deployment slot to configure the hybrid connection for.
  - `relay_id` - The ID of the Azure Relay hybrid connection to use.
  - `hostname` - The hostname of the endpoint.
  - `port` - The port to use for the endpoint.
  - `send_key_name` - (Optional) The name of the Relay key with Send permission to use. Defaults to 'RootManageSharedAccessKey'.

  Example:
  ```terraform
  web_app_slot_hybrid_connections = {
    staging_hybrid_conn = {
      slot_key      = "staging"
      relay_id      = "/subscriptions/.../hybridConnections/my-hybrid-connection"
      hostname      = "on-premises-server.local"
      port          = 1433
      send_key_name = "RootManageSharedAccessKey"
    }
  }
  ```
  DESCRIPTION
}
