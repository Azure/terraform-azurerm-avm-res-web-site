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
  sku_name            = "Y1"
}

# Use data object to reference an existing Key Vault and stored certificate
/*
data "azurerm_key_vault" "existing_keyvault" {
  name                = ""
  resource_group_name = ""
}
 
data "azurerm_key_vault_secret" "stored_certificate" {
  name         = ""
  key_vault_id = data.azurerm_key_vault.existing_keyvault.id
}
*/


# This is the module call
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.7.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-custom-domain"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "functionapp"
  os_type = azurerm_service_plan.example.os_type

  service_plan_resource_id = azurerm_service_plan.example.id

  function_app_storage_account_name       = module.avm_res_storage_storageaccount.name
  function_app_storage_account_access_key = module.avm_res_storage_storageaccount.resource.primary_access_key

  custom_domains = {
    # Allows for the configuration of custom domains for the Function App
    # If not already set, the module allows for the creation of TXT and CNAME records
    /*
    custom_domain_1 = {

      zone_resource_group_name = "<zone_resource_group_name>"

      create_txt_records = true
      txt_name           = "asuid.${module.naming.function_app.name_unique}"
      txt_zone_name      = "<zone_name>"
      txt_records = {
        record = {
          value = "" # Leave empty as module will reference Function App ID after Function App creation
        }
      }

      create_cname_records = true
      cname_name           = "${module.naming.function_app.name_unique}"
      cname_zone_name      = "<zone_name>"
      cname_record         = "${module.naming.function_app.name_unique}-custom-domain.azurewebsites.net"

      create_certificate   = true
      certificate_name     = "${module.naming.function_app.name_unique}-${data.azurerm_key_vault_secret.stored_certificate.name}"
      certificate_location = azurerm_resource_group.example.location
      pfx_blob             = data.azurerm_key_vault_secret.stored_certificate.value

      app_service_name    = "${module.naming.function_app.name_unique}-custom-domain"
      hostname            = "${module.naming.function_app.name_unique}.<root_domain>"
      resource_group_name = azurerm_resource_group.example.name
      ssl_state           = "SniEnabled"
      thumbprint_key      = "custom_domain_1" # Currently the key of the custom domain
    }
*/
  }

  tags = {
    environment = "dev-tf"
  }

}
