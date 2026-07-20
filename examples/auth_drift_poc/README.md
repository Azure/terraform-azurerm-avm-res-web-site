# Auth Drift POC

A minimal proof-of-concept demonstrating how to configure Azure App Service authentication with the AVM module without token drift.

## Drift Prevention Patterns

| Issue | Solution |
|-------|----------|
| `client_secret` changing causes Terraform diff | Use `client_secret_setting_name` pointing to app setting key |
| Secret rotation triggers unwanted updates | Store in Key Vault with `ignore_changes = [value]` |
| Azure auto-populates `token_store` fields | Explicitly set all fields (enabled, token_refresh_extension_hours) |
| Region changes destroy all resources | Use `random_integer` with `keepers` for stable selection |

## Usage

```bash
cd examples/auth_drift_poc
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Azure AD app registration details

terraform init
terraform apply
```

## Key Files

- `main.tf` - Complete drift-safe configuration
- `variables.tf` - Input variables for auth settings
- `locals.tf` - Pinned regions for stability