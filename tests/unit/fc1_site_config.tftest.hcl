mock_provider "azapi" {
  # Downstream submodules validate that parent_id looks like a real site
  # resource ID, so the default random mock ID has to be overridden.
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/func-avm-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

# Flex Consumption (FC1) enforcement of the ARM 51021 rejection list is
# region-dependent: older regions silently ignore the properties below while
# newer regions reject them. That makes the flex_consumption e2e example an
# unreliable regression signal, because it picks its region at random. These
# assertions run against the rendered request body instead, so they pin the
# behavior regardless of region. See issue #283.

variables {
  location                 = "eastus"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/serverfarms/asp-avm-test"
  enable_telemetry         = false
  kind                     = "functionapp"
  os_type                  = "Linux"

  # The shape that regressed in #283: an application stack supplied alongside
  # an FC1 plan, which made site_config_helpers derive "NODE|20".
  site_config = {
    application_stack = {
      node = {
        node_version = "20"
      }
    }
    app_scale_limit                  = 10
    pre_warmed_instance_count        = 2
    runtime_scale_monitoring_enabled = true
  }
}

run "fc1_omits_rejected_site_config_properties" {
  command = apply

  variables {
    name                        = "func-avm-fc1"
    function_app_uses_fc1       = true
    fc1_runtime_name            = "node"
    fc1_runtime_version         = "20"
    maximum_instance_count      = 100
    instance_memory_in_mb       = 2048
    storage_container_type      = "blobContainer"
    storage_container_endpoint  = "https://stavmtest.blob.core.windows.net/deployments"
    storage_authentication_type = "SystemAssignedIdentity"
  }

  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.linuxFxVersion, null) == null
    error_message = "siteConfig.linuxFxVersion must be omitted for Flex Consumption sites; ARM rejects it with error 51021."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.windowsFxVersion, null) == null
    error_message = "siteConfig.windowsFxVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.netFrameworkVersion, null) == null
    error_message = "siteConfig.netFrameworkVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.phpVersion, null) == null
    error_message = "siteConfig.phpVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.pythonVersion, null) == null
    error_message = "siteConfig.pythonVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.nodeVersion, null) == null
    error_message = "siteConfig.nodeVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.javaVersion, null) == null
    error_message = "siteConfig.javaVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.javaContainer, null) == null
    error_message = "siteConfig.javaContainer must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.javaContainerVersion, null) == null
    error_message = "siteConfig.javaContainerVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.powerShellVersion, null) == null
    error_message = "siteConfig.powerShellVersion must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.alwaysOn, null) == null
    error_message = "siteConfig.alwaysOn must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.ftpsState, null) == null
    error_message = "siteConfig.ftpsState must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.use32BitWorkerProcess, null) == null
    error_message = "siteConfig.use32BitWorkerProcess must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.preWarmedInstanceCount, null) == null
    error_message = "siteConfig.preWarmedInstanceCount must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.functionsRuntimeScaleMonitoringEnabled, null) == null
    error_message = "siteConfig.functionsRuntimeScaleMonitoringEnabled must be omitted for Flex Consumption sites."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.functionAppScaleLimit, null) == null
    error_message = "siteConfig.functionAppScaleLimit must be omitted for Flex Consumption sites."
  }

  # The runtime has to land somewhere, otherwise suppression would just be
  # dropping the caller's configuration on the floor.
  assert {
    condition     = try(azapi_resource.this.body.properties.functionAppConfig.runtime.name, null) == "node"
    error_message = "Flex Consumption apps express their runtime through functionAppConfig.runtime.name."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.functionAppConfig.runtime.version, null) == "20"
    error_message = "Flex Consumption apps express their runtime through functionAppConfig.runtime.version."
  }
}

run "non_fc1_still_sends_the_application_stack" {
  command = apply

  variables {
    name                  = "func-avm-standard"
    function_app_uses_fc1 = false
  }

  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.linuxFxVersion, null) == "NODE|20"
    error_message = "Non-FC1 Linux apps must still derive siteConfig.linuxFxVersion from site_config.application_stack."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.ftpsState, null) == "FtpsOnly"
    error_message = "Non-FC1 apps must still send siteConfig.ftpsState."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.preWarmedInstanceCount, null) == 2
    error_message = "Non-FC1 apps must still send siteConfig.preWarmedInstanceCount."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.functionAppScaleLimit, null) == 10
    error_message = "Non-FC1 function apps must still send siteConfig.functionAppScaleLimit."
  }
  assert {
    condition     = try(azapi_resource.this.body.properties.siteConfig.functionsRuntimeScaleMonitoringEnabled, null) == true
    error_message = "Non-FC1 function apps must still send siteConfig.functionsRuntimeScaleMonitoringEnabled."
  }
}
