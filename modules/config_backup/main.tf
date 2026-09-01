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
    # than clearing it, with a clean plan throughout (#378, and #382 for the
    # module-wide limits of `azapi_update_resource`).
    #
    # Verified: AzAPI's merge overwrites with an explicit null rather than
    # dropping it, so the null is transmitted. NOT verified: what Azure does with
    # it. No transition deployment — set a schedule, remove it, read it back —
    # has been run, so whether the null clears the stored schedule or is ignored
    # is unknown. The 2025-03-01 schema types `backupSchedule` as an object and
    # does not declare it nullable, so a null is out of contract either way.
    #
    # That unknown is why `enabled` carries a validation instead of being relied
    # on to paper over it. The API documents `enabled` as "true if the backup
    # schedule is enabled (must be included in that case), false if the backup
    # schedule should be disabled", so `enabled = true` without a schedule is
    # rejected at plan time. A caller who wants to stop backing up sets
    # `enabled = false`, which is the documented mechanism and does not depend on
    # how Azure treats the transmitted null. The null is still sent as the best
    # available clearing value; the disable is what actually carries the intent.
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
