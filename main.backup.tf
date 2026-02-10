resource "azapi_resource" "backup" {
  for_each = var.backup

  name      = "backup"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      backupName        = coalesce(each.value.name, "backup-${var.name}")
      enabled           = each.value.enabled
      storageAccountUrl = each.value.storage_account_url
      backupSchedule = each.value.schedule != null ? {
        for sk, sv in each.value.schedule : sk => {
          frequencyInterval     = sv.frequency_interval
          frequencyUnit         = sv.frequency_unit
          keepAtLeastOneBackup  = sv.keep_at_least_one_backup
          retentionPeriodInDays = sv.retention_period_days
          startTime             = sv.start_time
        }
      }[keys(each.value.schedule)[0]] : null
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
