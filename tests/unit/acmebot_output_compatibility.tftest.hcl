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
  private_endpoints = {
    acmebot = {
      name               = "acmebot-private-endpoint"
      subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
    }
  }
}

run "preserves_acmebot_output_contract" {
  command = apply

  assert {
    condition     = output.resource.name == "unit-test-site"
    error_message = "The root resource output must remain available to polymind-inc/terraform-azurerm-acmebot."
  }

  assert {
    condition = {
      for key, private_endpoint in coalesce(output.private_endpoints, {}) : key => {
        name        = private_endpoint.name
        resource_id = private_endpoint.id
      }
      } == {
      acmebot = {
        name        = "acmebot-private-endpoint"
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
      }
    }
    error_message = "The private endpoint output must retain the name and ID projection consumed by polymind-inc/terraform-azurerm-acmebot."
  }
}
