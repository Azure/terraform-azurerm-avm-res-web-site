# Storage with Managed Identity Authentication

This example deploys a Windows Function App that authenticates to its backing Storage Account using a managed identity instead of access keys.

By setting `storage_uses_managed_identity = true` and enabling a system-assigned managed identity, the Function App connects to Azure Storage without storing any secrets. An Azure role assignment (Storage Blob Data Owner) is created to grant the necessary permissions.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.

It reads the deployed app settings back from Azure and verifies the
identity-based setting pair is present and the plain `AzureWebJobsStorage`
connection string is absent. The assertions are data-source postconditions, so
an incorrect deployed value fails the E2E run rather than producing a warning.
Only those three paths are exported, and they are kept in AzAPI's sensitive
output so an unexpected connection string is not written to ordinary state.

These checks prove the configuration Azure stored for a new deployment. The
example does not deploy function code, so it does not prove Functions host
startup or an existing app's transition from a connection string.
