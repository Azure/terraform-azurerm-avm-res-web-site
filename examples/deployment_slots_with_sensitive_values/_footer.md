## Important Notes

- **Sensitive Values**: This example uses the `sensitive()` function to mark values as sensitive. In production, retrieve these from Azure Key Vault or other secure storage.
- **Key Vault Integration**: For production use, consider using Key Vault references in `app_settings` instead of passing secrets directly.
- **Security Best Practice**: Never commit sensitive values to source control. Use environment variables, CI/CD secrets, or secure parameter stores.

## How It Works

The fix wraps the `for_each` expression with `nonsensitive()` to extract only the slot names (keys) for use as resource keys. The actual sensitive values in `app_settings` remain protected and are accessed through `each.value`. This allows Terraform to iterate over deployment slots even when they contain sensitive configuration.

## Example Sensitive Values

In this example, we demonstrate:
- Database connection strings marked as sensitive
- API keys and secrets
- Third-party service credentials
- Environment-specific configurations

All of these can now be safely used in deployment slot configurations without Terraform plan errors.
