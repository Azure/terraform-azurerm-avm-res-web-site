mock_provider "azapi" {}
mock_provider "time" {}

variables {
  enable_telemetry         = false
  location                 = "eastus"
  name                     = "unit-test-site"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "site_defaults_to_deleting_an_empty_service_plan" {
  command = plan

  assert {
    condition     = azapi_resource.this.delete_query_parameters["deleteEmptyServerFarm"] == tolist(["true"])
    error_message = "By default the site should let Azure delete an empty App Service Plan, matching the REST API default."
  }
}

run "site_can_keep_an_empty_service_plan" {
  command = plan

  variables {
    delete_empty_service_plan = false
  }

  assert {
    condition     = azapi_resource.this.delete_query_parameters["deleteEmptyServerFarm"] == tolist(["false"])
    error_message = "Setting `delete_empty_service_plan` to `false` should send `deleteEmptyServerFarm=false` on the site delete request."
  }
}

run "slots_inherit_delete_empty_service_plan" {
  command = plan

  variables {
    delete_empty_service_plan = false
    deployment_slots = {
      staging = {}
    }
  }

  assert {
    condition     = module.slot["staging"].resource.delete_query_parameters["deleteEmptyServerFarm"] == tolist(["false"])
    error_message = "Deployment slots should inherit `delete_empty_service_plan` from the parent site."
  }
}
