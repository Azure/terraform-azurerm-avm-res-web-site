mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }
}
mock_provider "time" {}

run "existing_unkeyed_slot_connection_strings" {
  command   = apply
  state_key = "migration"

  module {
    source = "../../tests/unit/fixtures/legacy_slot_connectionstrings"
  }
}

run "move_existing_slot_connection_strings_without_replacement" {
  command   = apply
  state_key = "migration"

  variables {
    kind                     = "app"
    location                 = "eastus"
    name                     = "staging"
    os_type                  = "Windows"
    parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
    service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
  }

  assert {
    condition     = module.config_connectionstrings["default"].resource_id == run.existing_unkeyed_slot_connection_strings.connection_strings_id
    error_message = "An existing slot connection strings update must retain its resource ID when its module address gains the default key."
  }
}
