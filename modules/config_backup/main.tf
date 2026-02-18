resource "azapi_update_resource" "this" {
  name      = "backup"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      backupName        = var.backup_name
      enabled           = var.enabled
      storageAccountUrl = var.storage_account_url
      backupSchedule = var.schedule != null ? {
        frequencyInterval     = var.schedule.frequency_interval
        frequencyUnit         = var.schedule.frequency_unit
        keepAtLeastOneBackup  = var.schedule.keep_at_least_one_backup
        retentionPeriodInDays = var.schedule.retention_period_days
        startTime             = var.schedule.start_time
      } : null
    }
  }
  response_export_values = []
}
