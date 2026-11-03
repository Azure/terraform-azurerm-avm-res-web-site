# Slot counterpart of principal_id_from_identity_block.tftest.hcl: the slot's
# `identity_principal_id` must be read from the `identity` block, which AzAPI
# keeps known across in-place updates, not from `output.identity.principalId`,
# which AzAPI marks unknown on any in-place update.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
      output = {}
      identity = {
        principal_id = "11111111-2222-3333-4444-555555555555"
        tenant_id    = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "random" {}

mock_provider "time" {}

variables {
  kind                     = "app"
  location                 = "eastus"
  name                     = "staging"
  os_type                  = "Windows"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverFarms/unit-test-plan"
  managed_identities = {
    system_assigned = true
  }
}

run "bind_transitive_mock_provider_source" {
  command = apply

  module {
    source = "./tests/unit/fixtures/mock_provider_sources"
  }
}

run "slot_principal_id_comes_from_identity_block" {
  command = apply

  module {
    source = "./modules/slot"
  }

  assert {
    condition     = output.identity_principal_id == "11111111-2222-3333-4444-555555555555"
    error_message = "The slot's `identity_principal_id` must be read from the `identity` block, which stays known across in-place updates."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
