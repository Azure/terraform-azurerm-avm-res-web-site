# Storage with Managed Identity Authentication

This example deploys a Windows Function App that authenticates to its backing Storage Account using a managed identity instead of access keys.

By setting `storage_uses_managed_identity = true` and enabling a system-assigned managed identity, the Function App connects to Azure Storage without storing any secrets. An Azure role assignment (Storage Blob Data Owner) is created to grant the necessary permissions.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
