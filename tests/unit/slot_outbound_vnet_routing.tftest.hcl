# Slot counterpart of `outbound_vnet_routing.tftest.hcl`: `modules/slot` builds the same
# `outboundVnetRouting` object for `Microsoft.Web/sites/slots`, so it must also send every
# per-traffic-type flag as `true` when `vnet_route_all_traffic` is set.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
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
  kind                      = "app,linux"
  location                  = "eastus"
  name                      = "staging"
  os_type                   = "Linux"
  parent_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
  service_plan_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
  virtual_network_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
}

run "bind_transitive_mock_provider_source" {
  command = apply

  module {
    source = "./tests/unit/fixtures/mock_provider_sources"
  }
}

run "slot_route_all_traffic_sends_every_traffic_type_as_true" {
  command = apply

  module {
    source = "./modules/slot"
  }

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
    error_message = "With `vnet_route_all_traffic = true`, every per-traffic-type flag on the slot must be sent as `true` to match what Azure stores, got `${jsonencode(azapi_resource.this.body.properties.outboundVnetRouting)}`."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "slot_per_traffic_type_flags_apply_without_route_all_traffic" {
  command = apply

  module {
    source = "./modules/slot"
  }

  variables {
    vnet_content_share_enabled = true
  }

  assert {
    condition = azapi_resource.this.body.properties.outboundVnetRouting == {
      allTraffic           = false
      applicationTraffic   = false
      backupRestoreTraffic = false
      contentShareTraffic  = true
      imagePullTraffic     = false
    }
    error_message = "Without `vnet_route_all_traffic`, each slot per-traffic-type flag should follow its own input, got `${jsonencode(azapi_resource.this.body.properties.outboundVnetRouting)}`."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
