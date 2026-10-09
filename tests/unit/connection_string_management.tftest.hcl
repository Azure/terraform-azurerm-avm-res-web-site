mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry         = false
  location                 = "eastus"
  name                     = "unit-test-site"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "default_manages_empty_connection_strings" {
  command = apply

  assert {
    condition     = length(module.config_connectionstrings) == 1 && length(module.config_connectionstrings["default"].resource_id) > 0
    error_message = "The default must still manage the connection strings endpoint even for an omitted, empty map."
  }
}

run "explicit_empty_map_still_manages_connection_strings" {
  command = apply

  variables {
    connection_strings = {}
  }

  assert {
    condition     = length(module.config_connectionstrings) == 1
    error_message = "An explicitly empty connection strings map must not opt out of management."
  }
}

run "opt_out_skips_connection_strings_endpoint" {
  command = apply

  variables {
    manage_connection_strings = false
  }

  assert {
    condition     = length(module.config_connectionstrings) == 0
    error_message = "Opting out must omit the connection strings config update entirely."
  }
}

run "populated_map_remains_managed" {
  command = apply

  variables {
    connection_strings = {
      db = {
        type  = "Custom"
        value = "unit-test-value"
      }
    }
  }

  assert {
    condition     = length(module.config_connectionstrings) == 1
    error_message = "Populated connection strings must continue to be managed by default."
  }
}
