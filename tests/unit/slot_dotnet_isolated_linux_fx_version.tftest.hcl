mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/func-avm-test/slots/staging"
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
  kind                     = "functionapp,linux"
  is_function_app          = true
  location                 = "eastus"
  name                     = "staging"
  os_type                  = "Linux"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/func-avm-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/serverfarms/asp-avm-test"
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "10.0"
        use_dotnet_isolated_runtime = true
      }
    }
  }
}

run "bind_transitive_mock_provider_source" {
  command = apply

  module {
    source = "./tests/unit/fixtures/mock_provider_sources"
  }
}

run "isolated_function_slot_uses_isolated_stack" {
  command = apply

  module {
    source = "./modules/slot"
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.linuxFxVersion == "DOTNET-ISOLATED|10.0"
    error_message = "An isolated Linux Function App slot must send DOTNET-ISOLATED|10.0."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "web_app_slot_keeps_dotnetcore" {
  command = apply

  module {
    source = "./modules/slot"
  }

  variables {
    kind            = "app,linux"
    is_function_app = false
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.linuxFxVersion == "DOTNETCORE|10.0"
    error_message = "A Linux web app slot must keep the DOTNETCORE stack."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "explicit_slot_linux_stack_wins" {
  command = apply

  module {
    source = "./modules/slot"
  }

  variables {
    site_config = {
      linux_fx_version = "CUSTOM|10.0"
      application_stack = {
        dotnet = {
          dotnet_version              = "10.0"
          use_dotnet_isolated_runtime = true
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.linuxFxVersion == "CUSTOM|10.0"
    error_message = "An explicit slot linux_fx_version must take precedence over the isolated worker stack."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "flex_consumption_slot_omits_linux_stack" {
  command = apply

  module {
    source = "./modules/slot"
  }

  variables {
    function_app_uses_fc1 = true
  }

  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.linuxFxVersion, null) == null
    error_message = "A Flex Consumption slot must omit linuxFxVersion."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
