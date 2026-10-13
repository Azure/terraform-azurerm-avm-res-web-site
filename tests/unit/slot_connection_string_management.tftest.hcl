mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }
}
mock_provider "time" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  kind                     = "app"
  location                 = "eastus"
  name                     = "staging"
  os_type                  = "Windows"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "bind_transitive_mock_provider_source" {
  command = apply

  module {
    source = "./tests/unit/fixtures/mock_provider_sources"
  }
}

run "slot_default_manages_empty_connection_strings" {
  command = apply

  module {
    source = "./modules/slot"
  }

  assert {
    condition     = length(module.config_connectionstrings) == 1
    error_message = "A slot must manage its connection strings endpoint by default, including an empty map."
  }
}

run "slot_opt_out_skips_connection_strings_endpoint" {
  command = apply

  module {
    source = "./modules/slot"
  }

  variables {
    manage_connection_strings = false
  }

  assert {
    condition     = length(module.config_connectionstrings) == 0
    error_message = "Opting out on a slot must omit its connection strings config update."
  }
}
