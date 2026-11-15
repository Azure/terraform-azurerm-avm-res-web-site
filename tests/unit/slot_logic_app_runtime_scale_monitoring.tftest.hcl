mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/logic-avm-test/slots/staging"
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
  kind                     = "functionapp,workflowapp"
  is_logic_app             = true
  location                 = "eastus"
  name                     = "staging"
  os_type                  = "Windows"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/logic-avm-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/serverfarms/asp-avm-test"
  site_config = {
    runtime_scale_monitoring_enabled = true
  }
}

run "bind_transitive_mock_provider_source" {
  command = apply

  module {
    source = "./tests/unit/fixtures/mock_provider_sources"
  }
}

run "logic_app_slot_sends_runtime_scale_monitoring" {
  command = apply

  module {
    source = "./modules/slot"
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.functionsRuntimeScaleMonitoringEnabled == true
    error_message = "`site_config.runtime_scale_monitoring_enabled` must reach `siteConfig.functionsRuntimeScaleMonitoringEnabled` on a Logic App slot."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "web_app_slot_does_not_send_runtime_scale_monitoring" {
  command = apply

  module {
    source = "./modules/slot"
  }

  variables {
    kind         = "app"
    is_logic_app = false
  }

  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.functionsRuntimeScaleMonitoringEnabled, null) == null
    error_message = "Web App slots must not send `siteConfig.functionsRuntimeScaleMonitoringEnabled`."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
