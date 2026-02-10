# Deployment Slots with Sensitive App Settings

This example deploys a Windows Web App with three deployment slots (`test`, `staging`, `prod`) and uses the `slot_app_settings` variable to pass sensitive per-slot configuration values.

It demonstrates how to securely provide environment-specific settings such as database connection strings, API keys, and feature flags to individual deployment slots without exposing them in the main `app_settings`. The `slot_app_settings` variable is marked as sensitive, ensuring values are not shown in plan output.

The example uses `kind = "webapp"` and `os_type = "Windows"` with a .NET 8.0 application stack.
