# Windows Function App

This example deploys a Windows Function App in its simplest form with the minimum required configuration.

It provisions a Resource Group, App Service Plan, Storage Account (required for Function Apps), and the Function App itself. This serves as a baseline for Function App deployments and demonstrates the required `storage_account_name` and `storage_account_access_key` variables.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
