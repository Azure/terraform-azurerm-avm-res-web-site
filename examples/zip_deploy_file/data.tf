data "archive_file" "app" {
  type        = "zip"
  source_dir  = "${path.module}/resources_for_zip_deploy"
  output_path = "${path.module}/resources_for_zip_deploy.zip"
}

data "azapi_resource_action" "storage_keys" {
  action                 = "listKeys"
  method                 = "POST"
  resource_id            = azapi_resource.storage_account.id
  type                   = "Microsoft.Storage/storageAccounts@2025-01-01"
  response_export_values = ["keys"]
}
