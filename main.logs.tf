resource "azapi_resource" "logs" {
  for_each = var.logs

  name      = "logs"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = {
      detailedErrorMessages = {
        enabled = each.value.detailed_error_messages
      }
      failedRequestsTracing = {
        enabled = each.value.failed_request_tracing
      }
      applicationLogs = length(each.value.application_logs) > 0 ? {
        for alk, alv in each.value.application_logs : alk => {
          fileSystem = {
            level = alv.file_system_level
          }
          azureBlobStorage = alv.azure_blob_storage != null ? {
            level           = alv.azure_blob_storage.level
            retentionInDays = alv.azure_blob_storage.retention_in_days
            sasUrl          = alv.azure_blob_storage.sas_url
          } : null
        }
      }[keys(each.value.application_logs)[0]] : null
      httpLogs = length(each.value.http_logs) > 0 ? {
        for hlk, hlv in each.value.http_logs : hlk => {
          azureBlobStorage = hlv.azure_blob_storage_http != null ? {
            retentionInDays = hlv.azure_blob_storage_http.retention_in_days
            sasUrl          = hlv.azure_blob_storage_http.sas_url
          } : null
          fileSystem = hlv.file_system != null ? {
            retentionInDays = hlv.file_system.retention_in_days
            retentionInMb   = hlv.file_system.retention_in_mb
          } : null
        }
      }[keys(each.value.http_logs)[0]] : null
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
