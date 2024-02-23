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

provider "azurerm" {
  features {}
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

# locals {
#   test_regions = ["eastus2", "westus2", "centralus", "westeurope", "eastasia", "japaneast"]
# }

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

resource "azurerm_storage_account" "example" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name
}

resource "azurerm_service_plan" "example" {
  location = azurerm_resource_group.example.location
  # This will equate to Consumption (Serverless) in portal
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Y1"
}

# resource "azurerm_app_service_certificate" "example" {
#   name                = "example-cert"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   pfx_blob            = filebase64("")
#   password            = ""
# }

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = 0.1.0

  enable_telemetry = false # see variables.tf

  name                = "${module.naming.function_app.name_unique}-custom-domain"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  os_type = azurerm_service_plan.example.os_type # "Linux" / "Windows" / azurerm_service_plan.example.os_type

  service_plan_resource_id = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

#   custom_domains = {
#     custom_domain_1 = {
#         create_certificate = false
#       hostname            = "${module.test.name}.donvmccoy.com"
#       app_service_name    = module.test.name
#       resource_group_name = azurerm_resource_group.example.name
#       ssl_state           = "SniEnabled"
#       thumbprint          = azurerm_app_service_certificate.example.thumbprint
#     }
#   }

}

# module "keyvault" {
#   source  = "Azure/avm-res-keyvault-vault/azurerm"
#   version = "0.5.1"

#   name                = module.naming.key_vault.name_unique
#   enable_telemetry    = false
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   tenant_id           = data.azurerm_client_config.this.tenant_id

  
# }