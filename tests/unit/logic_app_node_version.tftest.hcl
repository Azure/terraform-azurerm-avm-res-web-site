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
    condition     = nonsensitive(module.config_appsettings.app_settings)["WEBSITE_NODE_DEFAULT_VERSION"] == "~22"
    error_message = "A Logic App should default to `~22`, matching the documented default for `logic_app_node_version`."
  }
}

run "logic_app_node_version_is_configurable" {
  command = apply

  variables {
    logic_app_node_version = "~20"
  }

  assert {
    condition     = nonsensitive(module.config_appsettings.app_settings)["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
    error_message = "Setting `logic_app_node_version` should change the `WEBSITE_NODE_DEFAULT_VERSION` app setting."
  }
}

run "null_logic_app_node_version_omits_the_setting" {
  command = apply

  variables {
    logic_app_node_version = null
  }

  assert {
    condition     = !contains(keys(nonsensitive(module.config_appsettings.app_settings)), "WEBSITE_NODE_DEFAULT_VERSION")
    error_message = "Setting `logic_app_node_version` to `null` should drop `WEBSITE_NODE_DEFAULT_VERSION` from the app settings entirely."
  }
}

# Regression guard for #282. The module merges its Logic App defaults after
# `var.app_settings`, so without an explicit gate it silently overwrites
# whatever the consumer set here.
#
# This run and `app_settings_wins_when_both_inputs_are_set` are the
# discriminating pair: strip the `!contains(keys(var.app_settings), ...)` clause
# from `local.logic_app_settings` and those two alone fail, while the other four
# still pass. If you are here to simplify that gate back to a plain null check,
# that is what you would be breaking.
run "explicit_app_settings_entry_beats_the_module_default" {
  command = apply

  variables {
    app_settings = {
      WEBSITE_NODE_DEFAULT_VERSION = "~20"
    }
  }

  assert {
    condition     = nonsensitive(module.config_appsettings.app_settings)["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
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
    condition     = nonsensitive(module.config_appsettings.app_settings)["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
    error_message = "When both `logic_app_node_version` and `app_settings.WEBSITE_NODE_DEFAULT_VERSION` are set, the `app_settings` entry must win."
  }
}

run "non_logic_app_kinds_do_not_get_a_node_version" {
  command = apply

  variables {
    kind = "webapp"
  }

  assert {
    condition     = !contains(keys(nonsensitive(module.config_appsettings.app_settings)), "WEBSITE_NODE_DEFAULT_VERSION")
    error_message = "Only Logic Apps should get a module-supplied `WEBSITE_NODE_DEFAULT_VERSION`."
  }
}
