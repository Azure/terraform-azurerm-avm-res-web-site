// `local.merged_app_settings` is the map the module hands
// `modules/config_appsettings` as its request body, so asserting on it covers
// the behavior these runs care about without publishing an output that just
// echoes the caller's own input back (TFFR2). This matches how
// `tests/unit/conditionally_required_variables.tftest.hcl` asserts on
// `local.body`.

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

run "logic_app_defaults_to_the_documented_node_version" {
  command = apply

  assert {
    condition     = local.merged_app_settings["WEBSITE_NODE_DEFAULT_VERSION"] == "~22"
    error_message = "A Logic App should default to `~22`, matching the documented default for `logic_app_node_version`."
  }
}

run "logic_app_node_version_is_configurable" {
  command = apply

  variables {
    logic_app_node_version = "~20"
  }

  assert {
    condition     = local.merged_app_settings["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
    error_message = "Setting `logic_app_node_version` should change the `WEBSITE_NODE_DEFAULT_VERSION` app setting."
  }
}

run "null_logic_app_node_version_omits_the_setting" {
  command = apply

  variables {
    logic_app_node_version = null
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "WEBSITE_NODE_DEFAULT_VERSION")
    error_message = "Setting `logic_app_node_version` to `null` should drop `WEBSITE_NODE_DEFAULT_VERSION` from the app settings entirely."
  }
}

# Regression guard for #282. The module merges its Logic App defaults after
# `var.app_settings`, so without an explicit gate it silently overwrites
# whatever the consumer set here.
#
# This run, `app_settings_wins_when_both_inputs_are_set`, and
# `lowercase_app_settings_entry_beats_the_module_default` are the discriminating
# set: strip the `!contains(local.app_settings_keys, ...)` clause from
# `local.logic_app_settings` and those three alone fail, while the rest still
# pass. If you are here to simplify that gate back to a plain null check, that
# is what you would be breaking.
run "explicit_app_settings_entry_beats_the_module_default" {
  command = apply

  variables {
    app_settings = {
      WEBSITE_NODE_DEFAULT_VERSION = "~20"
    }
  }

  assert {
    condition     = local.merged_app_settings["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
    error_message = "An explicit `WEBSITE_NODE_DEFAULT_VERSION` in `var.app_settings` must win over the module's `logic_app_node_version` default."
  }
}

# The run above leaves `logic_app_node_version` at its default, so it only
# proves `var.app_settings` beats the *default*. This one sets both inputs
# explicitly to different values, which pins the documented precedence rule
# itself rather than a property of the default value.
run "app_settings_wins_when_both_inputs_are_set" {
  command = apply

  variables {
    logic_app_node_version = "~18"
    app_settings = {
      WEBSITE_NODE_DEFAULT_VERSION = "~20"
    }
  }

  assert {
    condition     = local.merged_app_settings["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
    error_message = "When both `logic_app_node_version` and `app_settings.WEBSITE_NODE_DEFAULT_VERSION` are set, the `app_settings` entry must win."
  }
}

# Azure treats app setting names as case-insensitive, so the precedence rule
# above has to be too. Without the `lower()` normalization in
# `local.app_settings_keys` the module injects its own uppercase key alongside
# the caller's, and which one Azure keeps is anybody's guess — the same silent
# override #282 reported, just spelled differently.
run "lowercase_app_settings_entry_beats_the_module_default" {
  command = apply

  variables {
    app_settings = {
      website_node_default_version = "~20"
    }
  }

  assert {
    condition     = local.merged_app_settings["website_node_default_version"] == "~20"
    error_message = "A lowercase `website_node_default_version` in `var.app_settings` must survive, because Azure treats app setting names as case-insensitive."
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "WEBSITE_NODE_DEFAULT_VERSION")
    error_message = "When the caller has already set the Node version under any casing, the module must not also send its own `WEBSITE_NODE_DEFAULT_VERSION` key."
  }
}

# `var.app_settings` is nullable, so `null` has always been a legal value:
# `merge()` accepts it. Reading the caller's keys is what makes it fragile,
# because `keys(null)` fails with an opaque argument-must-not-be-null error
# rather than anything a consumer could act on. Hence the `coalesce()` in
# `local.app_settings`.
run "null_app_settings_still_plans_and_keeps_the_default" {
  command = apply

  variables {
    app_settings = null
  }

  assert {
    condition     = local.merged_app_settings["WEBSITE_NODE_DEFAULT_VERSION"] == "~22"
    error_message = "`app_settings = null` must still plan, and with no caller-supplied key the module default of `~22` still applies."
  }
}

run "non_logic_app_kinds_do_not_get_a_node_version" {
  command = apply

  variables {
    kind = "webapp"
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "WEBSITE_NODE_DEFAULT_VERSION")
    error_message = "Only Logic Apps should get a module-supplied `WEBSITE_NODE_DEFAULT_VERSION`."
  }
}
