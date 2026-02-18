resource "azapi_update_resource" "this" {
  name      = "logs"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = merge(
      {
        detailedErrorMessages = {
          enabled = var.detailed_error_messages
        }
        failedRequestsTracing = {
          enabled = var.failed_requests_tracing
        }
      },
      var.application_logs != null ? {
        applicationLogs = merge(
          {
            fileSystem = {
              level = var.application_logs.file_system.level
            }
          },
          var.application_logs.azure_blob_storage != null ? {
            azureBlobStorage = {
              level           = var.application_logs.azure_blob_storage.level
              retentionInDays = var.application_logs.azure_blob_storage.retention_in_days
              sasUrl          = var.application_logs.azure_blob_storage.sas_url
            }
          } : {}
        )
      } : {},
      var.http_logs != null ? {
        httpLogs = merge(
          {},
          var.http_logs.azure_blob_storage != null ? {
            azureBlobStorage = {
              retentionInDays = var.http_logs.azure_blob_storage.retention_in_days
              sasUrl          = var.http_logs.azure_blob_storage.sas_url
            }
          } : {},
          var.http_logs.file_system != null ? {
            fileSystem = {
              retentionInDays = var.http_logs.file_system.retention_in_days
              retentionInMb   = var.http_logs.file_system.retention_in_mb
            }
          } : {}
        )
      } : {}
    )
  }
  response_export_values = []
}
