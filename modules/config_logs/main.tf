resource "azapi_update_resource" "this" {
  name      = "logs"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      detailedErrorMessages = {
        enabled = var.detailed_error_messages
      }
      failedRequestsTracing = {
        enabled = var.failed_requests_tracing
      }
      applicationLogs = var.application_logs != null ? {
        fileSystem = {
          level = var.application_logs.file_system.level
        }
        azureBlobStorage = var.application_logs.azure_blob_storage != null ? {
          level           = var.application_logs.azure_blob_storage.level
          retentionInDays = var.application_logs.azure_blob_storage.retention_in_days
          sasUrl          = var.application_logs.azure_blob_storage.sas_url
        } : null
      } : null
      httpLogs = var.http_logs != null ? {
        azureBlobStorage = var.http_logs.azure_blob_storage != null ? {
          retentionInDays = var.http_logs.azure_blob_storage.retention_in_days
          sasUrl          = var.http_logs.azure_blob_storage.sas_url
        } : null
        fileSystem = var.http_logs.file_system != null ? {
          retentionInDays = var.http_logs.file_system.retention_in_days
          retentionInMb   = var.http_logs.file_system.retention_in_mb
        } : null
      } : null
    }
  }
  response_export_values = []
}
