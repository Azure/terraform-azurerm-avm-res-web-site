mock_provider "azapi" {}
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

run "logic_app_defaults_to_a_supported_node_lts" {
  command = plan

  assert {
    condition     = module.config_appsettings.resource.body.properties["WEBSITE_NODE_DEFAULT_VERSION"] == "~22"
    error_message = "A Logic App should default to Node.js 22, the current LTS that Standard Logic Apps supports."
  }
}

run "logic_app_node_version_is_configurable" {
  command = plan

  variables {
    logic_app_node_version = "~20"
  }

  assert {
    condition     = module.config_appsettings.resource.body.properties["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
    error_message = "Setting `logic_app_node_version` should change the `WEBSITE_NODE_DEFAULT_VERSION` app setting."
  }
}

run "null_logic_app_node_version_omits_the_setting" {
  command = plan

  variables {
    logic_app_node_version = null
  }

  assert {
    condition     = !contains(keys(module.config_appsettings.resource.body.properties), "WEBSITE_NODE_DEFAULT_VERSION")
    error_message = "Setting `logic_app_node_version` to `null` should drop `WEBSITE_NODE_DEFAULT_VERSION` from the app settings entirely."
  }
}

# Regression guard for #282. The module merges its Logic App defaults after
# `var.app_settings`, so without an explicit gate it silently overwrites
# whatever the consumer set here.
run "explicit_app_settings_entry_beats_the_module_default" {
  command = plan

  variables {
    app_settings = {
      WEBSITE_NODE_DEFAULT_VERSION = "~20"
    }
  }

  assert {
    condition     = module.config_appsettings.resource.body.properties["WEBSITE_NODE_DEFAULT_VERSION"] == "~20"
    error_message = "An explicit `WEBSITE_NODE_DEFAULT_VERSION` in `var.app_settings` must win over the module's `logic_app_node_version` default."
  }
}

run "non_logic_app_kinds_do_not_get_a_node_version" {
  command = plan

  variables {
    kind = "webapp"
  }

  assert {
    condition     = !contains(keys(module.config_appsettings.resource.body.properties), "WEBSITE_NODE_DEFAULT_VERSION")
    error_message = "Only Logic Apps should get a module-supplied `WEBSITE_NODE_DEFAULT_VERSION`."
  }
}
