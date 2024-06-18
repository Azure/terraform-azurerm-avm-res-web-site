terraform {
  required_version = ">= 1.3.0"
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

/*
module "avm_res_storage_storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.1.1"

  enable_telemetry = false
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.example.name
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
}
*/

/*
resource "azurerm_service_plan" "example" {
  location = azurerm_resource_group.example.location
  # This will equate to Consumption (Serverless) in portal
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Y1"
}
*/

module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.6.3"

  enable_telemetry = false

  name                = "${module.naming.function_app.name_unique}-default"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "webapp"
  os_type = "Windows"

  # site_config = {
  #   ftps_state = "FtpsOnly"
  # }


  /*
  # Uses an existing app service plan
  os_type = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id
  */

  # Creates a new app service plan
  create_service_plan = true
  new_service_plan = {
    sku_name = "S1"
  }

  /* 
  # Uses an existing storage account
  storage_account_name       = module.avm_res_storage_storageaccount.name
  storage_account_access_key = module.avm_res_storage_storageaccount.resource.primary_access_key
  */

  # Uses the avm-res-storage-storageaccount module to create a new storage account within root module
  # function_app_create_storage_account = true
  # function_app_storage_account = {
  #   name                = module.naming.storage_account.name_unique
  #   resource_group_name = azurerm_resource_group.example.name
  # }

  web_app_slots = {
    slot1 = {
      name = "staging"
      site_config = {
        always_on = true
      }
    },
    slot2 = {
      name = "development"
      site_config = {
        always_on         = true
        auto_heal_enabled = true
      }
      auto_heal_setting = {
        setting_1 = {
          action = {
            action_type                    = "Recycle"
            minimum_process_execution_time = "00:01:00"
          }
          trigger = {
            # private_bytes_in_kb = 0
            requests = {
              count    = 100
              interval = "00:00:30"
            }
            status_code = {
              status_5000 = {
                count             = 5000
                interval          = "00:05:00"
                path              = "/HealthCheck"
                status_code_range = 500
                sub_status        = 0
              }
              status_6000 = {
                count             = 6000
                interval          = "00:05:00"
                path              = "/Get"
                status_code_range = 500
                sub_status        = 0
              }
            }
          }
        }
      }
    }
  }

  app_service_active_slot = {
    slot_key                = "slot2"
    overwite_network_config = false
  }
}
