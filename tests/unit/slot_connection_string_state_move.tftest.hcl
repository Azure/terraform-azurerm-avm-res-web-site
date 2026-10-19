mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "time" {}

mock_provider "random" {}

run "bind_transitive_mock_provider_source" {
  command = apply

  module {
    source = "./tests/unit/fixtures/mock_provider_sources"
  }
}

run "existing_unkeyed_slot_connection_strings" {
  command   = apply
  state_key = "migration"

  module {
    source = "./tests/unit/fixtures/legacy_slot_connectionstrings"
  }
  variables {
    location = "eastus"
  }
}

run "move_existing_slot_connection_strings_without_replacement" {
  command   = apply
  state_key = "migration"

  module {
    source = "./modules/slot"
  }

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
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
