# AzAPI marks the whole `output` attribute unknown on any in-place update of the
# site, while the `identity` block (and its computed `principal_id`) keeps its
# prior value as long as the identity type and IDs are unchanged. The principal
# ID outputs must therefore come from the `identity` block, not from
# `output.identity.principalId`; otherwise every tag or setting change turns them
# into `(known after apply)` and forces replacement of downstream role
# assignments.
#
# The mock below returns an `output` without `identity` (as when it is not
# available) and a known `identity[0].principal_id`, so the outputs only resolve
# when they read the `identity` block.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
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
  enable_telemetry         = false
  location                 = "eastus"
  name                     = "unit-test-site"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
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

run "site_principal_id_comes_from_identity_block" {
  command = apply

  assert {
    condition     = output.system_assigned_mi_principal_id == "11111111-2222-3333-4444-555555555555"
    error_message = "`system_assigned_mi_principal_id` must be read from the `identity` block, which stays known across in-place updates."
  }

  assert {
    condition     = output.identity_principal_id == "11111111-2222-3333-4444-555555555555"
    error_message = "`identity_principal_id` must be read from the `identity` block, which stays known across in-place updates."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
