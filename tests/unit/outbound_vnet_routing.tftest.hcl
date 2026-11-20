# `outboundVnetRouting.allTraffic = true` enables every other routing option on the site:
# Azure returns `applicationTraffic`, `backupRestoreTraffic`, `contentShareTraffic` and
# `imagePullTraffic` as `true` whatever the request said. Sending `false` for those flags
# alongside `allTraffic = true` therefore produces a perpetual in-place diff, so the module
# sends them as `true` whenever `vnet_route_all_traffic` is set.

# Mock every provider in `terraform.tf`, and pin the mocked site ID: under `command =
# apply` a bare mock generates a random string for `azapi_resource.this.id`, which the
# config submodules reject because they validate `parent_id` as a real site resource ID.
mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
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
  enable_telemetry          = false
  location                  = "eastus"
  name                      = "unit-test-site"
  parent_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
  service_plan_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
  virtual_network_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
}

run "defaults_route_nothing_over_the_virtual_network" {
  command = apply

  assert {
    condition = azapi_resource.this.body.properties.outboundVnetRouting == {
      allTraffic           = false
      applicationTraffic   = false
      backupRestoreTraffic = false
      contentShareTraffic  = false
      imagePullTraffic     = false
    }
    error_message = "Every outboundVnetRouting flag should default to `false`, got `${jsonencode(azapi_resource.this.body.properties.outboundVnetRouting)}`."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "route_all_traffic_sends_every_traffic_type_as_true" {
  command = apply

  variables {
    vnet_route_all_traffic = true
  }

  assert {
    condition = azapi_resource.this.body.properties.outboundVnetRouting == {
      allTraffic           = true
      applicationTraffic   = true
      backupRestoreTraffic = true
      contentShareTraffic  = true
      imagePullTraffic     = true
    }
    error_message = "With `vnet_route_all_traffic = true`, every per-traffic-type flag must be sent as `true` to match what Azure stores, got `${jsonencode(azapi_resource.this.body.properties.outboundVnetRouting)}`."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "per_traffic_type_flags_apply_without_route_all_traffic" {
  command = apply

  variables {
    vnet_image_pull_enabled = true
  }

  assert {
    condition = azapi_resource.this.body.properties.outboundVnetRouting == {
      allTraffic           = false
      applicationTraffic   = false
      backupRestoreTraffic = false
      contentShareTraffic  = false
      imagePullTraffic     = true
    }
    error_message = "Without `vnet_route_all_traffic`, each per-traffic-type flag should follow its own input, got `${jsonencode(azapi_resource.this.body.properties.outboundVnetRouting)}`."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
