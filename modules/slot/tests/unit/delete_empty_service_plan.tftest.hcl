// Companion coverage to `tests/unit/delete_empty_service_plan.tftest.hcl`,
// which pins the same behavior on the site itself.
//
// Testing the slot from the root module meant reaching into it through an
// output that published a raw provider argument back to consumers, which is not
// something anyone would call the module for. Driving the submodule directly
// gets at the same resource attribute and leaves the root-to-slot assignment in
// `main.slots.tf` as the static wiring it is.
//
// As with the other submodule tests here, `mock_provider` does not run the
// azapi provider's own delete path, so this pins the query parameter we build,
// not Azure's handling of it.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }
}

variables {
  kind                     = "webapp"
  location                 = "eastus"
  name                     = "staging"
  os_type                  = "Windows"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "slot_defaults_to_deleting_an_empty_service_plan" {
  command = apply

  assert {
    condition     = azapi_resource.this.delete_query_parameters["deleteEmptyServerFarm"] == tolist(["true"])
    error_message = "By default a deployment slot should let Azure delete an empty App Service Plan, matching the REST API default."
  }
}

run "slot_can_keep_an_empty_service_plan" {
  command = apply

  variables {
    delete_empty_service_plan = false
  }

  assert {
    condition     = azapi_resource.this.delete_query_parameters["deleteEmptyServerFarm"] == tolist(["false"])
    error_message = "Setting `delete_empty_service_plan` to `false` should send `deleteEmptyServerFarm=false` on the slot delete request."
  }
}
