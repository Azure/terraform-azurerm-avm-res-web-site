mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
      output = {
        identity = {
          principalId = "11111111-2222-3333-4444-555555555555"
        }
      }
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
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverFarms/unit-test-plan"
  managed_identities = {
    system_assigned = true
  }
}

# `identity_principal_id` predates RMFR7, which names this output
# `system_assigned_mi_principal_id`. The old name is kept as an alias because
# published configurations pinned to earlier releases read it. This run records
# that the two names stay in lockstep, so neither can drift without failing.

run "identity_principal_id_aliases_system_assigned_mi_principal_id" {
  command = apply

  assert {
    condition     = output.system_assigned_mi_principal_id == "11111111-2222-3333-4444-555555555555"
    error_message = "`system_assigned_mi_principal_id` must resolve to the site's system-assigned managed identity principal ID."
  }

  assert {
    condition     = output.identity_principal_id == output.system_assigned_mi_principal_id
    error_message = "`identity_principal_id` is a deprecated alias and must keep resolving to the same value as `system_assigned_mi_principal_id`."
  }
}
