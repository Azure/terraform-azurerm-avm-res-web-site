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
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "create_with_initial_tags" {
  command = apply

  variables {
    tags = {
      environment = "initial"
    }
  }

  assert {
    condition     = azapi_resource.this.tags["environment"] == "initial"
    error_message = "The site should be created with the configured tags."
  }
}

run "tag_changes_are_planned" {
  command = plan

  variables {
    tags = {
      environment = "updated"
    }
  }

  assert {
    condition     = azapi_resource.this.tags["environment"] == "updated"
    error_message = "Changing tags must produce a planned update instead of retaining the prior state."
  }
}
