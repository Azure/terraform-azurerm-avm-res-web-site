variable "function_app_slot_hybrid_connections" {
  type = map(object({
    name            = string
    function_app_id = string
    relay_id        = string
    hostname        = string
    port            = number
    send_key_name   = optional(string, "RootManageSharedAccessKey")
    send_key_value  = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of hybrid connection configurations for Function App slots.
  
  - `name` - (Required) The name of the hybrid connection.
  - `function_app_id` - (Required) The ID of the function app slot.
  - `relay_id` - The ID of the Azure Relay hybrid connection to use.
  - `hostname` - The hostname of the endpoint.
  - `port` - The port to use for the endpoint.
  - `send_key_name` - (Optional) The name of the Relay key with Send permission to use. Defaults to 'RootManageSharedAccessKey'.
  - `send_key_value` - (Optional) The Send key value for the Relay. If not provided, will be retrieved automatically from the Relay.

  Example:
  ```terraform
  function_app_slot_hybrid_connections = {
    staging_hybrid_conn = {
      name            = "my-custom-connection"  # Required: custom name
      function_app_id = "/subscriptions/.../sites/my-function-app/slots/staging"  # Required: function app slot ID
      relay_id        = "/subscriptions/.../hybridConnections/my-hybrid-connection"
      hostname        = "on-premises-server.local"
      port            = 1433
      send_key_name   = "RootManageSharedAccessKey"
    }
  }
  ```
  DESCRIPTION
}

variable "web_app_slot_hybrid_connections" {
  type = map(object({
    name           = string
    web_app_id     = string
    relay_id       = string
    hostname       = string
    port           = number
    send_key_name  = optional(string, "RootManageSharedAccessKey")
    send_key_value = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of hybrid connection configurations for Web App slots.
  
  - `name` - (Required) The name of the hybrid connection.
  - `web_app_id` - (Required) The ID of the web app slot.
  - `relay_id` - The ID of the Azure Relay hybrid connection to use.
  - `hostname` - The hostname of the endpoint.
  - `port` - The port to use for the endpoint.
  - `send_key_name` - (Optional) The name of the Relay key with Send permission to use. Defaults to 'RootManageSharedAccessKey'.
  - `send_key_value` - (Optional) The Send key value for the Relay. If not provided, will be retrieved automatically from the Relay.

  Example:
  ```terraform
  web_app_slot_hybrid_connections = {
    staging_hybrid_conn = {
      name        = "my-custom-connection"  # Required: custom name
      web_app_id  = "/subscriptions/.../sites/my-web-app/slots/staging"  # Required: web app slot ID
      relay_id    = "/subscriptions/.../hybridConnections/my-hybrid-connection"
      hostname    = "on-premises-server.local"
      port        = 1433
      send_key_name = "RootManageSharedAccessKey"
    }
  }
  ```
  DESCRIPTION
}
