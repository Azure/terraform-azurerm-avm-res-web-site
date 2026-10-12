mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/func-avm-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry         = false
  kind                     = "functionapp"
  location                 = "eastus"
  name                     = "func-avm-test"
  os_type                  = "Linux"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test"
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

run "isolated_linux_function_app_uses_isolated_stack" {
  command = apply

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.linuxFxVersion == "DOTNET-ISOLATED|10.0"
    error_message = "Isolated Linux Function Apps must send DOTNET-ISOLATED|10.0."
  }
}

run "isolated_dotnet_8_also_uses_isolated_stack" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        dotnet = {
          dotnet_version              = "8.0"
          use_dotnet_isolated_runtime = true
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.linuxFxVersion == "DOTNET-ISOLATED|8.0"
    error_message = "The isolated worker stack must not depend on the .NET version."
  }
}

run "nonisolated_linux_function_app_keeps_dotnetcore" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        dotnet = {
          dotnet_version              = "10.0"
          use_dotnet_isolated_runtime = false
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.linuxFxVersion == "DOTNETCORE|10.0"
    error_message = "Non-isolated Linux Function Apps must keep their DOTNETCORE stack."
  }
}

run "linux_web_app_keeps_dotnetcore" {
  command = apply

  variables {
    kind = "webapp"
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.linuxFxVersion == "DOTNETCORE|10.0"
    error_message = "The isolated worker setting must not change a Linux web app's stack."
  }
}

run "windows_function_app_omits_linux_stack" {
  command = apply

  variables {
    os_type = "Windows"
  }

  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.linuxFxVersion, null) == null
    error_message = "Windows Function Apps must not send linuxFxVersion."
  }
  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.netFrameworkVersion == "10.0"
    error_message = "Windows Function Apps must continue to use netFrameworkVersion."
  }
}

run "flex_consumption_omits_linux_stack" {
  command = apply

  variables {
    function_app_uses_fc1       = true
    fc1_runtime_name            = "dotnet-isolated"
    fc1_runtime_version         = "10.0"
    maximum_instance_count      = 100
    instance_memory_in_mb       = 2048
    storage_container_type      = "blobContainer"
    storage_container_endpoint  = "https://stavmtest.blob.core.windows.net/deployments"
    storage_authentication_type = "SystemAssignedIdentity"
  }

  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.linuxFxVersion, null) == null
    error_message = "Flex Consumption must omit linuxFxVersion even for isolated .NET."
  }
  assert {
    condition     = azapi_resource.this.body.properties.functionAppConfig.runtime.name == "dotnet-isolated"
    error_message = "Flex Consumption must use functionAppConfig.runtime instead."
  }
}

run "explicit_linux_stack_wins" {
  command = apply

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
    error_message = "An explicit linux_fx_version must take precedence over the derived isolated stack."
  }
}
