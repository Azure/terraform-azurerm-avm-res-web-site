# Unit tests for issue #373: collection variables with a non-null default that
# were still nullable, so an explicit `null` reached the module body.
#
# Each run passes `null` for one variable and asserts the variable resolved to
# its declared default instead. Before `nullable = false` these plans failed
# outright (`length()`/`for_each` rejecting null, an attribute lookup on null,
# or a submodule reporting "required variable may not be set to null" against a
# variable the caller never sees). The assertions are deliberately written as
# `var.x != null && length(var.x) == 0` rather than `var.x == {}`, because an
# empty `map(object(...))` and an empty object literal compare unequal.
#
# `retry` is intentionally excluded from that treatment. It is the one variable
# in this set where `null` already planned cleanly and means something distinct
# from the default: it disables retries on every AzAPI resource this module
# declares. The two `retry` runs pin both halves of that contract.
#
# These runs use `command = plan`. Per the note in
# `conditionally_required_variables.tftest.hcl` (issue #349), any run that leans
# on variable-level evaluation has to stay on `plan`: validation happens during
# the plan stage, so `command = apply` reports "the apply operation could not be
# executed and so the overall test case will be marked as a failure" and fails
# the run even when the outcome is the expected one. `plan` is enough here in
# any case, since the regression being guarded is that these values blow up
# while the plan graph is being built.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Web/sites/app-unit-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  location                 = "eastus"
  name                     = "app-unit-test"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Web/serverfarms/asp-test"
  enable_telemetry         = false
}

# `always_ready` is only dereferenced when `function_app_uses_fc1` is true, so
# the Flex Consumption inputs are required to reach the failing expression.
run "null_always_ready_uses_default" {
  command = plan

  variables {
    kind                              = "functionapp"
    os_type                           = "Linux"
    function_app_uses_fc1             = true
    fc1_runtime_name                  = "node"
    fc1_runtime_version               = "20"
    storage_authentication_type       = "UserAssignedIdentity"
    storage_container_endpoint        = "https://sttest.blob.core.windows.net/deployments"
    storage_user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-test"
    always_ready                      = null
  }

  assert {
    condition     = var.always_ready != null && length(var.always_ready) == 0
    error_message = "An explicit null for always_ready should resolve to the empty default."
  }
  assert {
    condition     = local.body.properties.functionAppConfig.scaleAndConcurrency.alwaysReady == null
    error_message = "An empty always_ready should omit alwaysReady from the Flex Consumption body."
  }
}

run "null_backup_uses_default" {
  command = plan

  variables {
    backup = null
  }

  assert {
    condition     = var.backup != null && length(var.backup) == 0
    error_message = "An explicit null for backup should resolve to the empty default."
  }
}

run "null_connection_strings_uses_default" {
  command = plan

  variables {
    connection_strings = null
  }

  assert {
    condition     = var.connection_strings != null && length(var.connection_strings) == 0
    error_message = "An explicit null for connection_strings should resolve to the empty default."
  }
}

run "null_site_config_uses_default" {
  command = plan

  variables {
    site_config = null
  }

  assert {
    condition     = var.site_config != null && var.site_config.always_on == true
    error_message = "An explicit null for site_config should resolve to the default object."
  }
}

run "null_slots_storage_shares_sensitive_values_uses_default" {
  command = plan

  variables {
    slots_storage_shares_to_mount_sensitive_values = null
    deployment_slots = {
      staging = {}
    }
  }

  assert {
    condition     = nonsensitive(var.slots_storage_shares_to_mount_sensitive_values) != null && length(nonsensitive(var.slots_storage_shares_to_mount_sensitive_values)) == 0
    error_message = "An explicit null for slots_storage_shares_to_mount_sensitive_values should resolve to the empty default."
  }
}

run "null_sticky_settings_uses_default" {
  command = plan

  variables {
    sticky_settings = null
  }

  assert {
    condition     = var.sticky_settings != null && length(var.sticky_settings) == 0
    error_message = "An explicit null for sticky_settings should resolve to the empty default."
  }
}

run "null_storage_shares_to_mount_uses_default" {
  command = plan

  variables {
    storage_shares_to_mount = null
  }

  assert {
    condition     = var.storage_shares_to_mount != null && length(var.storage_shares_to_mount) == 0
    error_message = "An explicit null for storage_shares_to_mount should resolve to the empty default."
  }
}

# `retry` stays nullable on purpose. Passing null is how a caller opts out of
# retries entirely, and it has always planned cleanly, so forcing the default
# back on would be a silent behavior change rather than a fix.
run "null_retry_is_preserved" {
  command = plan

  variables {
    retry = null
  }

  assert {
    condition     = var.retry == null
    error_message = "An explicit null for retry should be preserved, so that retries stay disabled."
  }
}

run "unset_retry_uses_default" {
  command = plan

  assert {
    condition     = var.retry != null && var.retry.interval_seconds == 10
    error_message = "An unset retry should resolve to the default retry-on-conflict configuration."
  }
}
