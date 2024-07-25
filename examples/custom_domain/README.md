<!-- BEGIN_TF_DOCS -->


```hcl
terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

# tflint-ignore: terraform_module_provider_declaration, terraform_output_separate, terraform_variable_separate
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

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

module "avm_res_storage_storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.1.2"

  enable_telemetry              = var.enable_telemetry
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
}

resource "azurerm_service_plan" "example" {
  location = azurerm_resource_group.example.location
  # This will equate to Consumption (Serverless) in portal
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "S1"
}

# Use data object to reference an existing Key Vault and stored certificate
/*
data "azurerm_key_vault" "existing_keyvault" {
  name                = "vault3-4-24"
  resource_group_name = "rg-test"
}
# /*
data "azurerm_key_vault_secret" "stored_certificate" {
  key_vault_id = data.azurerm_key_vault.existing_keyvault.id
  name         = "donvmccoy"
}
*/


# This is the module call
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.8.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-custom-domain"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "functionapp"
  os_type = azurerm_service_plan.example.os_type

  service_plan_resource_id = azurerm_service_plan.example.id

  function_app_storage_account_name       = module.avm_res_storage_storageaccount.name
  function_app_storage_account_access_key = module.avm_res_storage_storageaccount.resource.primary_access_key

  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "v8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }

  deployment_slots = {
    qa = {
      name = "qa"
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    },
    dev = {
      name = "dev"
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
  }

  custom_domains = {
    # Allows for the configuration of custom domains for the Function App
    # If not already set, the module allows for the creation of TXT and CNAME records
    /*
    production = {

      zone_resource_group_name = "<zone_resource_group_name>"

      create_txt_records = true
      txt_name           = "asuid.${module.naming.function_app.name_unique}-custom-domain"
      txt_zone_name      = "<zone_name>"
      txt_records = {
        record = {
          value = "" # Feel free to leave empty, as module will reference Function App ID after Function App creation
        }
      }

      create_cname_records = true
      cname_name           = "${module.naming.function_app.name_unique}-custom-domain"
      cname_zone_name      = "<zone_name>"
      cname_record         = "${module.naming.function_app.name_unique}-custom-domain.azurewebsites.net"

      create_certificate   = true
      certificate_name     = "${module.naming.function_app.name_unique}-${data.azurerm_key_vault_secret.stored_certificate.name}"
      certificate_location = azurerm_resource_group.example.location
      pfx_blob             = data.azurerm_key_vault_secret.stored_certificate.value

      app_service_name    = "${module.naming.function_app.name_unique}-custom-domain"
      hostname            = "${module.naming.function_app.name_unique}-custom-domain.donvmccoy.com"
      resource_group_name = azurerm_resource_group.example.name
      ssl_state           = "SniEnabled"
      thumbprint_key      = "production" # Currently the key of the custom domain
    },
    qa = {
      slot_as_target = true

      zone_resource_group_name = "rg-personal-domain"

      create_txt_records = true
      txt_name           = "asuid.${module.naming.function_app.name_unique}-qa"
      txt_zone_name      = "<zone_name>"
      txt_records = {
        record = {
          value = "" # Leave empty as module will reference Function App ID after Function App creation
        }
      }

      create_cname_records = true
      cname_name           = "${module.naming.function_app.name_unique}-qa"
      cname_zone_name      = "<zone_name>"
      cname_record         = "${module.naming.function_app.name_unique}-custom-domain-qa.azurewebsites.net"

      # create_certificate   = true
      # certificate_name     = "${module.naming.function_app.name_unique}-${data.azurerm_key_vault_secret.stored_certificate.name}"
      # certificate_location = azurerm_resource_group.example.location
      # pfx_blob             = data.azurerm_key_vault_secret.stored_certificate.value

      app_service_slot_key = "qa"
      hostname = "${module.naming.function_app.name_unique}-qa.donvmccoy.com"
      ssl_state           = "SniEnabled"
      thumbprint_key      = "production"
    }
    */
  }

  tags = {
    environment = "dev-tf"
  }

}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.6)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.7.0, < 4.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.7.0, < 4.0.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

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

### <a name="output_name"></a> [name](#output\_name)

Description: Name for the resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_uri"></a> [resource\_uri](#output\_resource\_uri)

Description: This is the URI for the resource.

## Modules

The following Modules are called:

### <a name="module_avm_res_storage_storageaccount"></a> [avm\_res\_storage\_storageaccount](#module\_avm\_res\_storage\_storageaccount)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: 0.1.2

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