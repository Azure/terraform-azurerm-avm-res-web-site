<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module as a Linux Web App utilizing auto heal settings.

```hcl
## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.10.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-slots"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "webapp"
  os_type = "Linux"

  site_config = {
    # auto_heal_enabled = true
    # auto_heal_enabled = false # This will throw a module and provider error.
    auto_heal_enabled = null # `auto_heal_setting` cannot be set if `auto_heal_enabled` is set to `null`. `null` is the default value for `auto_heal_enabled`

  }
  auto_heal_setting = { # auto_heal_setting should only be specified if auto_heal_enabled is set to `true`
    # setting_1 = {
    #   action = {
    #     action_type                    = "Recycle"
    #     minimum_process_execution_time = "00:01:00"
    #   }
    #   trigger = {
    #     requests = {
    #       count    = 100
    #       interval = "00:00:30"
    #     }
    #     status_code = {
    #       status_5000 = {
    #         count             = 5000
    #         interval          = "00:05:00"
    #         path              = "/HealthCheck"
    #         status_code_range = 500
    #         sub_status        = 0
    #       }
    #       status_6000 = {
    #         count             = 6000
    #         interval          = "00:05:00"
    #         path              = "/Get"
    #         status_code_range = 500
    #         sub_status        = 0
    #       }
    #     }
    #   }
    # }
  }

  # Creates a new app service plan
  create_service_plan = true
  new_service_plan = {
    sku_name               = var.sku_for_testing
    zone_balancing_enabled = var.redundancy_for_testing
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.6.1)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.7.0, < 4.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_redundancy_for_testing"></a> [redundancy\_for\_testing](#input\_redundancy\_for\_testing)

Description: n/a

Type: `string`

Default: `"false"`

### <a name="input_sku_for_testing"></a> [sku\_for\_testing](#input\_sku\_for\_testing)

Description: n/a

Type: `string`

Default: `"S1"`

## Outputs

The following outputs are exported:

### <a name="output_active_slot"></a> [active\_slot](#output\_active\_slot)

Description: ID of active slot

### <a name="output_deployment_slots"></a> [deployment\_slots](#output\_deployment\_slots)

Description: Full output of deployment slots created

### <a name="output_name"></a> [name](#output\_name)

Description: This is the full output for the resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account)

Description: Full output of storage account created

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.3.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: >= 0.3.0

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->