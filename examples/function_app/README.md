<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module with a Windows Function App in its simplest form.

```hcl
## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.8.0"
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

resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "P1v2"
  tags = {
    app = "${module.naming.function_app.name_unique}-default"
  }
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_log_analytics_workspace" "example_production" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-production"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "functionapp"
  location = azurerm_resource_group.example.location
  name     = "${module.naming.function_app.name_unique}-functionapp"
  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  }
  enable_telemetry           = var.enable_telemetry
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # Uses an existing storage account
  storage_account_name = azurerm_storage_account.example.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.16.4"
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.9)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.example_production](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
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

## Outputs

The following outputs are exported:

### <a name="output_location"></a> [location](#output\_location)

Description: This is the full output for the resource.

### <a name="output_name"></a> [name](#output\_name)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This is the full output for the resource.

### <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id)

Description: The ID of the app service

### <a name="output_service_plan_name"></a> [service\_plan\_name](#output\_service\_plan\_name)

Description: Full output of service plan created

### <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name)

Description: The number of workers

### <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id)

Description: The ID of the storage account

### <a name="output_storage_account_kind"></a> [storage\_account\_kind](#output\_storage\_account\_kind)

Description: The kind of storage account

### <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name)

Description: Full output of storage account created

### <a name="output_storage_account_replication_type"></a> [storage\_account\_replication\_type](#output\_storage\_account\_replication\_type)

Description: The kind of storage account

### <a name="output_worker_count"></a> [worker\_count](#output\_worker\_count)

Description: The number of workers

### <a name="output_zone_redundant"></a> [zone\_redundant](#output\_zone\_redundant)

Description: The number of workers

## Modules

The following Modules are called:

### <a name="module_avm_res_web_site"></a> [avm\_res\_web\_site](#module\_avm\_res\_web\_site)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.3.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: >= 0.8.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->