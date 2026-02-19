# Default Example

This example deploys an Azure App Service (Web App) using the module's default settings.

It provisions only the minimum required resources: a Resource Group, an App Service Plan (Linux), and the Web App itself. No optional features are configured, making this the simplest possible deployment and a good starting point for understanding the module.

The module defaults to `kind = "webapp"` and `os_type = "Linux"`.
