# Deployment Slots with Sensitive Values

This example demonstrates how to use sensitive values (such as connection strings, API keys, and secrets) in deployment slot configurations. 

After the fix in issue #255, you can now safely include sensitive values in your `deployment_slots` configuration without encountering Terraform errors. The module automatically handles sensitive values by using `nonsensitive()` on the slot keys while keeping the actual sensitive values protected.

## Key Features Demonstrated

- Using sensitive variables in deployment slot app settings
- Multiple deployment slots (staging, production) with different sensitive configurations
- Integration with Azure Key Vault references
- Proper handling of connection strings and API keys
