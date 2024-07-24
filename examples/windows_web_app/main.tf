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

resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "S1"
}

# This is the module call
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.7.4"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.app_service.name_unique}-windows"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "webapp"
  os_type = azurerm_service_plan.example.os_type

  service_plan_resource_id = azurerm_service_plan.example.id

  site_config = {
    # auto_heal_enabled = true
  }

  # auto_heal_setting = {
  #   setting_1 = {
  #     action = {
  #       action_type = "Recycle"
  #       minimum_process_execution_time = "00:01:00"
  #     }
  #     trigger = {
  #       # private_bytes_in_kb = 0
  #       requests = {
  #         count = 100
  #         interval = "00:00:30"
  #       }
  #       status_code = {
  #         status_5000 = {
  #           count = 5000
  #           interval = "00:05:00"
  #           path = "/HealthCheck"
  #           status_code_range = 500
  #           sub_status = 0
  #         }
  #         status_6000 = {
  #           count = 6000
  #           interval = "00:05:00"
  #           path = "/Get"
  #           status_code_range = 500
  #           sub_status = 0
  #         }
  #       }
  #     }
  #   }
  # }

}
