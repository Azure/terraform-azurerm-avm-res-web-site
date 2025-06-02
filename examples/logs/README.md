<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module with a Linux Web App with logs configured on both the main app and deployment slot.

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
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "S1"
  tags = {
    app = "${module.naming.function_app.name_unique}-logs"
  }
}

resource "azurerm_application_insights" "example_staging" {
  application_type    = "web"
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.application_insights.name_unique}-staging"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example_staging.id
}

resource "azurerm_log_analytics_workspace" "example_production" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-production"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "example_staging" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-staging"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "example_development" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-development"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

# This is the module call
module "avm_res_web_site" {
  source = "../.."

  kind                     = "webapp"
  location                 = azurerm_resource_group.example.location
  name                     = "${module.naming.function_app.name_unique}-logs"
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  }
  deployment_slots = {
    slot1 = {
      name                                           = "development-logs"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        slot_application_insights_object_key = "development" # This is the key for the slot application insights mapping
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
      logs = {
        app_service_logs = {
          application_logs = {
            file_system_level = {
              file_system_level = "Warning"
            }
          }
          http_logs = {
            file_system_level = {
              file_system = {
                retention_in_days = 7
                retention_in_mb   = 35
              }
            }
          }
        }
      }
    }
    slot2 = {
      name                                           = "staging-logs"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        # Uses existing application insights
        application_insights_connection_string = nonsensitive(azurerm_application_insights.example_staging.connection_string)
        application_insights_key               = nonsensitive(azurerm_application_insights.example_staging.instrumentation_key)
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }

      logs = {
        app_service_logs = {
          application_logs = {
            file_system_level = {
              file_system_level = "Off"
            }
          }
          http_logs = {
            file_system_level = {
              file_system = {
                retention_in_days = 7
                retention_in_mb   = 35
              }
            }
          }
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  logs = {
    app_service_logs = {
      # Added validation to ensure that logs object is configured.
      # If file_system_level is set to "Off", then http_logs will have no effect
      # logs set in `logs`
      application_logs = {
        file_system_level = {
          file_system_level = "Off"
        }
      }
      # Added validation to ensure that is http_logs is configured, application_logs must also be configured.
      http_logs = {
        file_system_level = {
          file_system = {
            retention_in_days = 7
            retention_in_mb   = 35
          }
        }
      }
    }
  }
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }
  # Creates application insights for slot
  slot_application_insights = {
    development = {
      name                  = "${module.naming.application_insights.name_unique}-development"
      workspace_resource_id = azurerm_log_analytics_workspace.example_development.id
      inherit_tags          = true
    }
  }
  tags = {

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

- [azurerm_application_insights.example_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) (resource)
- [azurerm_log_analytics_workspace.example_development](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_log_analytics_workspace.example_production](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_log_analytics_workspace.example_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
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

### <a name="output_worker_count"></a> [worker\_count](#output\_worker\_count)

Description: The number of workers

### <a name="output_zone_redundant"></a> [zone\_redundant](#output\_zone\_redundant)

Description: The number of workers

## Modules

The following Modules are called:

### <a name="module_avm_res_web_site"></a> [avm\_res\_web\_site](#module\_avm\_res\_web\_site)

Source: ../..

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