mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
    }
  }

  mock_data "azapi_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000001"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  location                 = "eastus"
  name                     = "unit-test-site"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "site_defaults_to_deleting_an_empty_service_plan" {
  command = apply

  assert {
    condition     = azapi_resource.this.delete_query_parameters["deleteEmptyServerFarm"] == tolist(["true"])
    error_message = "By default the site should let Azure delete an empty App Service Plan, matching the REST API default."
  }
}

run "site_can_keep_an_empty_service_plan" {
  command = apply

  variables {
    delete_empty_service_plan = false
  }

  assert {
    condition     = azapi_resource.this.delete_query_parameters["deleteEmptyServerFarm"] == tolist(["false"])
    error_message = "Setting `delete_empty_service_plan` to `false` should send `deleteEmptyServerFarm=false` on the site delete request."
  }
}
