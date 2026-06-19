# Azure Web App Production Ready Module

A production-ready Terraform module for provisioning Azure Web Apps (Linux and Windows) along with an App Service Plan. This module is designed with best practices, including robust lifecycle management to prevent drift when properties are managed externally (e.g., via CI/CD pipelines).

## Features

- **Encapsulated Resources**: Packages the App Service Plan and the Web App together.
- **Drift Prevention**: Implements a `lifecycle { ignore_changes = [...] }` block for external settings (like `app_settings` and `site_config`).
- **Production Defaults**: Uses system-assigned managed identities, enforce standard tags, and production-ready `sku_name` (P1v2).
- **Test-Driven**: Includes tests for both Native Terraform testing (`terraform test`) and Terratest.

## Where is the Lifecycle Block?

The `lifecycle` block is placed inside the `azurerm_linux_web_app` and `azurerm_windows_web_app` resources in `main.tf`:

```hcl
  # IMPORTANT: Prevent drift from external configuration (e.g. CI/CD)
  lifecycle {
    ignore_changes = [
      app_settings,
      site_config,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }
```

This prevents Terraform from reverting configuration values (like connection strings or app variables) that get updated from pipelines or the Azure Portal.

## Testing

### Native Terraform Tests (`>= 1.6`)

Run the following command from the module root:

```bash
terraform test
```

### Terratest Integration Tests

To run the integration tests using Terratest (requires Go to be installed):

```bash
cd tests
go mod tidy
go test -v -timeout 30m
```

### Terraform Compliance

You can validate this module against your organization's policies using `terraform-compliance`:

```bash
terraform plan -out=plan.out
terraform-compliance -p plan.out -f git:https://github.com/your-org/compliance-policies.git
```
