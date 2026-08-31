resource "azapi_update_resource" "this" {
  name      = "backup"
  parent_id = var.parent_id
  type      = var.resource_types.web_sites_config
  body = {
    # `backupSchedule` is contributed by a conditional `merge` arm rather than
    # emitted as an explicit `null`, so it is absent from the request body when
    # no schedule is configured. That is what `ignore_null_property` would do if
    # `azapi_update_resource` offered it, and a key absent from `body` is never
    # compared against the response. Unlike `authsettingsV2` there is no field
    # report of Azure materialising this sub-object; this is the same construct
    # kept consistent rather than a confirmed repro. See #368.
    properties = merge(
      {
        backupName        = var.backup_name
        enabled           = var.enabled
        storageAccountUrl = var.storage_account_url
      },
      var.schedule != null ? {
        backupSchedule = {
          frequencyInterval     = var.schedule.frequency_interval
          frequencyUnit         = var.schedule.frequency_unit
          keepAtLeastOneBackup  = var.schedule.keep_at_least_one_backup
          retentionPeriodInDays = var.schedule.retention_period_days
          startTime             = var.schedule.start_time
        }
      } : {},
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
