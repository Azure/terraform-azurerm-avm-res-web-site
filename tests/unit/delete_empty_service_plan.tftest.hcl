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

run "slots_inherit_delete_empty_service_plan" {
  command = apply

  # A single flat `mock_resource` default hands every `azapi_resource` the same
  # site-shaped ID, including the slot itself. The slot's own child resources
  # then reject that `parent_id` because they expect a
  # `Microsoft.Web/sites/slots` ID, so give the slot a correctly shaped one.
  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  variables {
    delete_empty_service_plan = false
    deployment_slots = {
      staging = {}
    }
  }

  assert {
    condition     = module.slot["staging"].delete_query_parameters["deleteEmptyServerFarm"] == tolist(["false"])
    error_message = "Deployment slots should inherit `delete_empty_service_plan` from the parent site."
  }
}
