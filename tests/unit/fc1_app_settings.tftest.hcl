// `local.merged_app_settings` is the map the module hands
// `modules/config_appsettings` as its request body, so asserting on it covers
// the behavior these runs care about without publishing an output that just
// echoes the caller's own input back (TFFR2). This matches how
// `tests/unit/logic_app_node_version.tftest.hcl` asserts on the same local.
//
// Flex Consumption *deprecates* these settings rather than rejecting them, so
// unlike the siteConfig properties in `tests/unit/fc1_site_config.tftest.hcl`
// there is no ARM error to reproduce and an e2e deployment can never fail on
// them. Plan-time assertions are the only signal available. See issue #365.

mock_provider "azapi" {
  # Downstream submodules validate that parent_id looks like a real site
  # resource ID, so the default random mock ID has to be overridden.
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/func-avm-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry         = false
  kind                     = "functionapp"
  location                 = "eastus"
  name                     = "func-avm-test"
  os_type                  = "Linux"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/serverfarms/asp-avm-test"
}

run "fc1_omits_the_deprecated_app_settings" {
  command = apply

  variables {
    content_share_force_disabled = true
    fc1_runtime_name             = "node"
    fc1_runtime_version          = "20"
    function_app_uses_fc1        = true
    storage_authentication_type  = "SystemAssignedIdentity"
    storage_container_endpoint   = "https://stavmtest.blob.core.windows.net/deployments"
    storage_container_type       = "blobContainer"
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "FUNCTIONS_EXTENSION_VERSION")
    error_message = "Flex Consumption deprecates `FUNCTIONS_EXTENSION_VERSION` and sets it from the backend, so the module must not send it."
  }
  assert {
    condition     = !contains(keys(local.merged_app_settings), "WEBSITE_CONTENTSHARE")
    error_message = "Flex Consumption has no content share, so `content_share_force_disabled` must not produce a `WEBSITE_CONTENTSHARE` key."
  }
}

# The gate is only defensible if it is narrow: everything else the module sends
# for a Function App is absent from the Flex Consumption deprecation table and
# must survive.
run "fc1_still_sends_the_settings_that_are_not_deprecated" {
  command = apply

  variables {
    builtin_logging_enabled     = false
    fc1_runtime_name            = "node"
    fc1_runtime_version         = "20"
    function_app_uses_fc1       = true
    storage_authentication_type = "SystemAssignedIdentity"
    storage_container_endpoint  = "https://stavmtest.blob.core.windows.net/deployments"
    storage_container_type      = "blobContainer"
  }

  assert {
    condition     = local.merged_app_settings["AzureWebJobsFeatureFlags"] == "EnableWorkerIndexing"
    error_message = "`AzureWebJobsFeatureFlags` is not on the Flex Consumption deprecation list and must still be sent."
  }
  assert {
    condition     = contains(keys(local.merged_app_settings), "AzureWebJobsDashboard")
    error_message = "`AzureWebJobsDashboard` is not on the Flex Consumption deprecation list and must still be sent."
  }
}

run "non_fc1_still_sends_the_extension_version" {
  command = apply

  variables {
    content_share_force_disabled = true
    function_app_uses_fc1        = false
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_EXTENSION_VERSION"] == "~4"
    error_message = "A non-Flex Consumption Function App must still get `FUNCTIONS_EXTENSION_VERSION`, defaulting to `~4`."
  }
  assert {
    condition     = local.merged_app_settings["WEBSITE_CONTENTSHARE"] == ""
    error_message = "`content_share_force_disabled` must still empty `WEBSITE_CONTENTSHARE` outside Flex Consumption."
  }
}

run "non_fc1_extension_version_is_configurable" {
  command = apply

  variables {
    functions_extension_version = "~3"
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_EXTENSION_VERSION"] == "~3"
    error_message = "Setting `functions_extension_version` should change the `FUNCTIONS_EXTENSION_VERSION` app setting."
  }
}

# The module merges its Function App defaults after `var.app_settings`, so
# without an explicit gate it silently overwrites whatever the consumer set
# here. This is the same shape #344 fixed for WEBSITE_NODE_DEFAULT_VERSION.
#
# This run, `app_settings_wins_when_both_inputs_are_set` and
# `lowercase_app_settings_entry_beats_the_module_default` are the discriminating
# set for the `!contains(local.app_settings_keys, ...)` clause: strip it and
# those three alone fail, while the rest still pass.
run "explicit_app_settings_entry_beats_the_module_default" {
  command = apply

  variables {
    app_settings = {
      FUNCTIONS_EXTENSION_VERSION = "~3"
    }
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_EXTENSION_VERSION"] == "~3"
    error_message = "An explicit `FUNCTIONS_EXTENSION_VERSION` in `var.app_settings` must win over the module's `functions_extension_version` default."
  }
}

# The run above leaves `functions_extension_version` at its default, so it only
# proves `var.app_settings` beats the *default*. This one sets both inputs
# explicitly to different values, which pins the documented precedence rule
# itself rather than a property of the default value.
run "app_settings_wins_when_both_inputs_are_set" {
  command = apply

  variables {
    functions_extension_version = "~4"
    app_settings = {
      FUNCTIONS_EXTENSION_VERSION = "~3"
    }
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_EXTENSION_VERSION"] == "~3"
    error_message = "When both `functions_extension_version` and `app_settings.FUNCTIONS_EXTENSION_VERSION` are set, the `app_settings` entry must win."
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
      functions_extension_version = "~3"
    }
  }

  assert {
    condition     = local.merged_app_settings["functions_extension_version"] == "~3"
    error_message = "A lowercase `functions_extension_version` in `var.app_settings` must survive, because Azure treats app setting names as case-insensitive."
  }
  assert {
    condition     = !contains(keys(local.merged_app_settings), "FUNCTIONS_EXTENSION_VERSION")
    error_message = "When the caller has already set the extension version under any casing, the module must not also send its own `FUNCTIONS_EXTENSION_VERSION` key."
  }
}

# The override guard is what keeps the Flex Consumption gate from being a wall.
# A caller who has a reason to pin the value on FC1 can still say so directly,
# and the module must not second-guess that.
run "fc1_keeps_an_explicit_app_settings_entry" {
  command = apply

  variables {
    fc1_runtime_name            = "node"
    fc1_runtime_version         = "20"
    function_app_uses_fc1       = true
    storage_authentication_type = "SystemAssignedIdentity"
    storage_container_endpoint  = "https://stavmtest.blob.core.windows.net/deployments"
    storage_container_type      = "blobContainer"
    app_settings = {
      FUNCTIONS_EXTENSION_VERSION = "~4"
    }
  }

  assert {
    condition     = local.merged_app_settings["FUNCTIONS_EXTENSION_VERSION"] == "~4"
    error_message = "Gating the module default must not strip a `FUNCTIONS_EXTENSION_VERSION` the caller set explicitly through `var.app_settings`."
  }
}

run "non_function_app_kinds_do_not_get_an_extension_version" {
  command = apply

  variables {
    kind = "webapp"
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "FUNCTIONS_EXTENSION_VERSION")
    error_message = "Only Function Apps should get a module-supplied `FUNCTIONS_EXTENSION_VERSION`."
  }
}
