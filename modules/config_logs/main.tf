resource "azapi_update_resource" "this" {
  name      = "logs"
  parent_id = var.parent_id
  type      = var.resource_types.web_sites_config
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
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.ignore_body_changes.web_sites_config) == 0
      error_message = "`ignore_body_changes` is not supported here. This module manages its resource with `azapi_update_resource`, which the AzAPI provider does not give an `ignore_body_changes` argument, so any value set would be silently ignored."
    }
  }
}
