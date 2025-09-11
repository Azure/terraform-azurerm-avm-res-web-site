# Function App Slot Hybrid Connection Example

This example demonstrates how to configure hybrid connections for Function App deployment slots using the AVM Web Site module.

## Overview

This example creates:
- A Windows Function App with a deployment slot named "staging"
- An Azure Relay namespace and hybrid connection
- A hybrid connection configuration between the Function App slot and an on-premises endpoint

## Features Demonstrated

- Function App deployment slots configuration
- Azure Relay hybrid connection setup
- Slot-specific hybrid connection configuration using `azapi_resource`

## Usage

1. Clone this repository
2. Navigate to this example directory
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan the deployment:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Important Notes

- Hybrid connections are only supported on dedicated App Service Plans (Basic, Standard, Premium, or Isolated tiers)
- The example uses a P1v2 App Service Plan to support hybrid connections
- The hybrid connection endpoint (hostname and port) should be configured to match your on-premises resources
- The `send_key_name` defaults to "RootManageSharedAccessKey" but can be customized for enhanced security

## Configuration

The hybrid connection is configured in the module call:

```hcl
function_app_slot_hybrid_connections = {
  staging_hybrid_conn = {
    slot_key      = "staging"
    relay_id      = azurerm_relay_hybrid_connection.example.id
    hostname      = "on-premises-server.local"
    port          = 1433
    send_key_name = "RootManageSharedAccessKey"
  }
}
```

## Outputs

- `function_app_id`: The ID of the Function App
- `function_app_slot_hybrid_connections`: The hybrid connection configurations for the slots
