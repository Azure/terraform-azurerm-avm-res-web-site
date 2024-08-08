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

# module "avm_res_storage_storageaccount" {
#   source  = "Azure/avm-res-storage-storageaccount/azurerm"
#   version = "0.1.2"

#   enable_telemetry              = var.enable_telemetry
#   name                          = module.naming.storage_account.name_unique
#   resource_group_name           = azurerm_resource_group.example.name
#   location                      = azurerm_resource_group.example.location
#   shared_access_key_enabled     = true
#   public_network_access_enabled = true
#   network_rules = {
#     bypass         = ["AzureServices"]
#     default_action = "Allow"
#   }
# }

# resource "azurerm_service_plan" "example" {
#   location            = azurerm_resource_group.example.location
#   name                = module.naming.app_service_plan.name_unique
#   os_type             = "Linux"
#   resource_group_name = azurerm_resource_group.example.name
#   sku_name            = "Y1"
# }

# This is the module call
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.9.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.app_service.name_unique}-linux"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "webapp"
  os_type = "Linux"

  create_service_plan = true
  new_service_plan = {
    sku_name = "S1"
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

  logs = {
    app_service_logs = {
      http_logs = {
        config1 = {
          file_system = {
            retention_in_days = 30
            retention_in_mb   = 35
          }
        }
      }
      application_logs = {
        config1 = {
          file_system_level = "Warning"
        }
      }
    }
  }

  deployment_slots = {
    slot1 = {
      name = "staging"
      site_config = {
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
          http_logs = {
            config1 = {
              file_system = {
                retention_in_days = 30
                retention_in_mb   = 35
              }
            }
          }
          application_logs = {
            config1 = {
              file_system_level = "Warning"
            }
          }
        }
      }
    }
  }

  # service_plan_resource_id = azurerm_service_plan.example.id

  # function_app_create_storage_account = true
  # function_app_storage_account = {
  #   name                = module.naming.storage_account.name_unique
  #   location            = azurerm_resource_group.example.location
  #   resource_group_name = azurerm_resource_group.example.name
  #   lock                = null
  # }

  # function_app_storage_account_name       = module.avm_res_storage_storageaccount.name
  # function_app_storage_account_access_key = module.avm_res_storage_storageaccount.resource.primary_access_key
}
