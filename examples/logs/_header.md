# Logs Configuration

This example deploys a Linux Web App with logging configured on both the main app and a deployment slot using the `logs` variable.

It demonstrates how to enable application logs (file system and Azure Blob Storage), HTTP logs, detailed error messages, and failed request tracing. Logs configuration helps with debugging and monitoring your App Service in production.

The example uses `kind = "webapp"` and `os_type = "Linux"`.
