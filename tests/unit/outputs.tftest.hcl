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
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverFarms/unit-test-plan"
  deployment_slots = {
    staging = {
      managed_identities = {
        system_assigned = true
      }
    }
  }
  managed_identities = {
    system_assigned = true
  }
}

run "downstream_outputs_do_not_require_sensitive_declarations" {
  command = apply

  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  assert {
    condition     = !issensitive(output.identity_principal_id)
    error_message = "An ordinary downstream output must be able to consume `identity_principal_id` without declaring `sensitive = true`."
  }

  assert {
    condition     = !issensitive(output.resource_id)
    error_message = "An ordinary downstream output must be able to consume `resource_id` without declaring `sensitive = true`."
  }

  assert {
    condition     = !issensitive(output.system_assigned_mi_principal_id)
    error_message = "An ordinary downstream output must be able to consume `system_assigned_mi_principal_id` without declaring `sensitive = true`."
  }

  assert {
    condition     = !issensitive(output.system_assigned_mi_principal_id_slots)
    error_message = "An ordinary downstream output must be able to consume `system_assigned_mi_principal_id_slots` without declaring `sensitive = true`."
  }
}
