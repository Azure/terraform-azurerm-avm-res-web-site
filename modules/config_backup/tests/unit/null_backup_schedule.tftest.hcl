// Companion coverage to `modules/config_authsettingsv2/tests/unit/null_nested_objects.tftest.hcl`
// for the second body in this module that emitted a nested object as an explicit
// `null` (#368). `schedule` is optional all the way up — the root passes `null`
// whenever a `backup` entry omits its schedule — so `backupSchedule = null` was
// reachable from ordinary configuration.
//
// Unlike `authsettingsV2` there is no field report of Azure materialising this
// particular sub-object, so this is the prophylactic half of the fix. It is
// behaviour-preserving either way: omitting a key is exactly what the provider's
// own `ignore_null_property` does before it sends the request, and a key that is
// absent from `body` is never compared against the response.

mock_provider "azapi" {}

variables {
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
}

run "unscheduled_backup_omits_the_schedule" {
  command = apply

  variables {
    backup_name         = "unit-test-backup"
    enabled             = true
    storage_account_url = "https://unittest.blob.core.windows.net/backups?sv=stub"
  }

  assert {
    condition     = !can(azapi_update_resource.this.body.properties.backupSchedule)
    error_message = "`backupSchedule` must be absent from the body when no schedule is supplied, rather than emitted as null (#368)."
  }

  // The rest of the backup configuration is unconditional and must be unaffected
  // by moving the schedule into a `merge` arm.
  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.backupName) == "unit-test-backup", false)
    error_message = "`backupName` must still reach the body."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.enabled) == true, false)
    error_message = "`enabled` must still reach the body."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.storageAccountUrl) == "https://unittest.blob.core.windows.net/backups?sv=stub", false)
    error_message = "`storageAccountUrl` must still reach the body."
  }
}

run "scheduled_backup_sends_the_schedule" {
  command = apply

  variables {
    backup_name         = "unit-test-backup"
    enabled             = true
    storage_account_url = "https://unittest.blob.core.windows.net/backups?sv=stub"

    schedule = {
      frequency_interval       = 7
      frequency_unit           = "Day"
      keep_at_least_one_backup = true
      retention_period_days    = 30
      start_time               = "2026-01-01T00:00:00Z"
    }
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.backupSchedule.frequencyInterval) == 7, false)
    error_message = "A supplied schedule must reach the request body, so a scheduled backup keeps being reconciled."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.backupSchedule.frequencyUnit) == "Day", false)
    error_message = "A supplied `frequency_unit` must reach the request body unchanged."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.backupSchedule.keepAtLeastOneBackup) == true, false)
    error_message = "A supplied `keep_at_least_one_backup` must reach the request body unchanged."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.backupSchedule.retentionPeriodInDays) == 30, false)
    error_message = "A supplied `retention_period_days` must reach the request body unchanged."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.backupSchedule.startTime) == "2026-01-01T00:00:00Z", false)
    error_message = "A supplied `start_time` must reach the request body unchanged."
  }
}
