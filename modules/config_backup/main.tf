resource "azapi_update_resource" "this" {
  name      = "backup"
  parent_id = var.parent_id
  type      = var.resource_types.web_sites_config
  body = {
    # `backupSchedule` stays an explicit `null` when no schedule is configured.
    # #377 briefly omitted the key instead, on the theory that a key absent from
    # `body` is never compared against the response. That is true, and it is also
    # why omission is the wrong tool here: `azapi_update_resource` merges the
    # configured body over what Azure already holds, so an omitted key keeps its
    # previous value. Removing a schedule would have stopped managing it rather
    # than clearing it, and a later `enabled = true` could resume a schedule the
    # caller had deleted, with a clean plan throughout.
    #
    # There was never a field report of Azure materialising this sub-object, so
    # #377 traded working clearing behaviour for silent retention to gain
    # consistency it did not need. See #378, and #382 for the module-wide limits
    # of `azapi_update_resource`.
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
