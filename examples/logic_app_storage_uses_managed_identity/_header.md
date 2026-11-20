# Logic App (Standard) with identity-based host storage

This example deploys a Windows Logic App (Standard) on a Workflow Service Plan (WS1). The Logic App authenticates to its host storage account with a user-assigned managed identity instead of a connection string.

The example sets `storage_uses_managed_identity = true` and attaches one user-assigned identity. The module selects that identity for `AzureWebJobsStorage__managedIdentityResourceId`, derives the Blob, Queue and Table service URIs from `storage_account_name`, and omits `AzureWebJobsStorage`. It does not need `storage_account_access_key`, because the example does not configure a content share.

The example also does these steps from [Set up managed identity access to your storage account](https://learn.microsoft.com/azure/logic-apps/create-single-tenant-workflows-azure-portal#set-up-managed-identity-access-to-your-storage-account):

- It gives the identity the `Storage Account Contributor`, `Storage Blob Data Owner`, `Storage Queue Data Contributor` and `Storage Table Data Contributor` roles on the storage account.
- It sets `site_config.runtime_scale_monitoring_enabled = true`, which the Workflow Service Plan requires.

The example reads the deployed app settings back from Azure. Data-source postconditions make sure that the identity settings are present and that `AzureWebJobsStorage` is absent. These checks prove the configuration that Azure stored for a new deployment. They do not prove that the workflow runtime starts.
