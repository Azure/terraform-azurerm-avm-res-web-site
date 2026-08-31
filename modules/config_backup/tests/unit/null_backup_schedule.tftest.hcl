// `schedule` is optional all the way up — the root passes `null` whenever a
// `backup` entry omits its schedule — so `backupSchedule = null` is reachable
// from ordinary configuration.
//
// #377 briefly omitted the key instead of sending the null, to match the
// treatment `authsettingsV2` needed for #368. That was wrong here.
// `azapi_update_resource` merges the configured body over what Azure already
// holds, so an omitted key keeps its previous value: a caller who removed a
// schedule would have stopped managing it rather than clearing it, and a later
// `enabled = true` could resume a schedule they had deleted. There was never a
// field report of Azure materialising this sub-object, so the omission bought
// consistency at the cost of correctness (#378).
//
// The explicit `null` is the behaviour these runs pin.

mock_provider "azapi" {}

variables {
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
}

run "unscheduled_backup_clears_the_schedule" {
  command = apply

  variables {
    backup_name         = "unit-test-backup"
    enabled             = true
    storage_account_url = "https://unittest.blob.core.windows.net/backups?sv=stub"
  }

  assert {
    condition     = azapi_update_resource.this.body.properties.backupSchedule == null
    error_message = "`backupSchedule` must be sent as an explicit null when no schedule is supplied, so removing a schedule clears it rather than leaving the previous one live (#378)."
  }

  // The rest of the backup configuration is unconditional and must be unaffected.
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
