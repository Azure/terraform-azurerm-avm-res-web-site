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

run "existing_unkeyed_connection_strings" {
  command   = apply
  state_key = "migration"

  module {
    source = "./tests/unit/fixtures/legacy_connectionstrings"
  }
}

run "move_existing_connection_strings_without_replacement" {
  command   = apply
  state_key = "migration"

  variables {
    enable_telemetry         = false
    location                 = "eastus"
    name                     = "unit-test-site"
    parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
    service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
  }

  assert {
    condition     = module.config_connectionstrings["default"].resource_id == run.existing_unkeyed_connection_strings.connection_strings_id
    error_message = "An existing connection strings update must retain its resource ID when its module address gains the default key."
  }
}
