// `local.merged_app_settings` is the map the module hands
// `modules/config_appsettings` as its request body, so asserting on it covers
// the behavior these runs care about without publishing an output that just
// echoes the caller's own input back (TFFR2). This matches how
// `tests/unit/logic_app_node_version.tftest.hcl` and
// `tests/unit/conditionally_required_variables.tftest.hcl` assert on locals.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/logic-avm-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry           = false
  kind                       = "logicapp"
  location                   = "eastus"
  name                       = "unit-test-logic-app"
  os_type                    = "Windows"
  parent_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
  service_plan_resource_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
  storage_account_access_key = "unit-test-key"
  storage_account_name       = "unittestsa"
}

# Issue #362. The module shipped `node`, which the app settings reference now
# describes as the previous value; `dotnet` is required for all new and existing
# deployed Standard Logic Apps.
run "logic_app_defaults_to_the_documented_worker_runtime" {
  command = apply

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_WORKER_RUNTIME"] == "dotnet"
    error_message = "A Logic App must default to the documented `dotnet` worker runtime."
  }
}

# `FUNCTIONS_WORKER_RUNTIME` is a required setting, so unlike the Node version
# there is no root variable that can null it out. Whatever else these runs
# assert, the key itself is never absent from a Logic App.
run "the_worker_runtime_is_always_present_on_a_logic_app" {
  command = apply

  variables {
    logic_app_node_version    = null
    logic_app_runtime_version = "~4"
    use_extension_bundle      = false
  }

  assert {
    condition     = contains(keys(local.merged_app_settings), "FUNCTIONS_WORKER_RUNTIME")
    error_message = "Azure requires `FUNCTIONS_WORKER_RUNTIME` on a Standard Logic App, so no combination of inputs may drop it."
  }
}

# The module merges its Logic App defaults after `var.app_settings`, so without
# an explicit gate it silently overwrites whatever the consumer set — the bug
# class #344 fixed one line above this setting. A caller mid-migration who still
# needs `node` has nowhere else to say so.
run "explicit_app_settings_entry_beats_the_module_default" {
  command = apply

  variables {
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "node"
    }
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_WORKER_RUNTIME"] == "node"
    error_message = "An explicit `FUNCTIONS_WORKER_RUNTIME` in `var.app_settings` must win over the module default."
  }
}

# Azure treats app setting names as case-insensitive, so the precedence rule
# above has to be too. Without the `lower()` normalization in
# `local.app_settings_keys` the module injects its own uppercase key alongside
# the caller's, and which one Azure keeps is anybody's guess.
run "lowercase_app_settings_entry_beats_the_module_default" {
  command = apply

  variables {
    app_settings = {
      functions_worker_runtime = "node"
    }
  }

  assert {
    condition     = local.merged_app_settings["functions_worker_runtime"] == "node"
    error_message = "A lowercase `functions_worker_runtime` in `var.app_settings` must survive, because Azure treats app setting names as case-insensitive."
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "FUNCTIONS_WORKER_RUNTIME")
    error_message = "When the caller has already set the worker runtime under any casing, the module must not also send its own `FUNCTIONS_WORKER_RUNTIME` key."
  }
}

# `var.app_settings` is nullable, and reading the caller's keys is what makes
# that fragile: `keys(null)` fails with an opaque argument-must-not-be-null
# error. Hence the `coalesce()` in `local.app_settings`.
run "null_app_settings_still_plans_and_keeps_the_default" {
  command = apply

  variables {
    app_settings = null
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_WORKER_RUNTIME"] == "dotnet"
    error_message = "`app_settings = null` must still plan, and with no caller-supplied key the module default of `dotnet` still applies."
  }
}

run "web_apps_do_not_get_a_worker_runtime" {
  command = apply

  variables {
    kind = "webapp"
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "FUNCTIONS_WORKER_RUNTIME")
    error_message = "Only Logic Apps should get a module-supplied `FUNCTIONS_WORKER_RUNTIME`."
  }
}

# Function Apps carry a `FUNCTIONS_WORKER_RUNTIME` of their own in Azure, but
# this module has never set it for them and #362 does not change that: the value
# depends on the language stack the consumer deployed, which the module cannot
# infer. Pinning it here so the Logic App default is not later generalized into
# one for every Functions host.
run "function_apps_do_not_get_a_worker_runtime" {
  command = apply

  variables {
    kind    = "functionapp"
    os_type = "Linux"
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "FUNCTIONS_WORKER_RUNTIME")
    error_message = "The module must not invent a `FUNCTIONS_WORKER_RUNTIME` for Function Apps; the value depends on the consumer's language stack."
  }
}

# A Function App caller who does set the runtime themselves must still see it,
# which is the other half of "non-Logic-App kinds are unaffected".
run "function_app_app_settings_entry_survives" {
  command = apply

  variables {
    kind    = "functionapp"
    os_type = "Linux"
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "python"
    }
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_WORKER_RUNTIME"] == "python"
    error_message = "A Function App caller's own `FUNCTIONS_WORKER_RUNTIME` must pass through untouched."
  }
}
