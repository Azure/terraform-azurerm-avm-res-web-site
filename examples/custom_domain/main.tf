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
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = 0.1.1

  enable_telemetry = true # see variables.tf

  name                = "${module.naming.function_app.name_unique}-custom-domain"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  os_type = azurerm_service_plan.example.os_type # "Linux" / "Windows" / azurerm_service_plan.example.os_type

  service_plan_resource_id = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  custom_domains = {
    # Allows for the configuration of custom domains for the Function App
    # If not already set, the module allows for the creation of TXT and CNAME records
    /*
    custom_domain_1 = {

      zone_resource_group_name = "<resource_group_name where zone is located>"

      create_txt_records = true
      txt_name           = "asuid.${module.naming.function_app.name_unique}"
      txt_zone_name      = "<domain_name>"
      txt_records = {
        record = {
          value = "" # Leave empty as module will reference Function App ID after Function App creation
        }
      }

      create_cname_records = true
      cname_name           = "${module.naming.function_app.name_unique}"
      cname_zone_name      = "<domain_name"
      cname_record         = "${module.naming.function_app.name_unique}-custom-domain.azurewebsites.net"

      create_certificate   = true
      certificate_name     = "${module.naming.function_app.name_unique}-${data.azurerm_key_vault_secret.stored_certificate.name}"
      certificate_location = azurerm_resource_group.example.location
      pfx_blob             = data.azurerm_key_vault_secret.stored_certificate.value

      app_service_name    = "${module.naming.function_app.name_unique}-custom-domain"
      hostname            = "${module.naming.function_app.name_unique}.<domain_name>"
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

# module "keyvault" {
#   source  = "Azure/avm-res-keyvault-vault/azurerm"
#   version = "0.5.1"

#   name                = module.naming.key_vault.name_unique
#   enable_telemetry    = false
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   tenant_id           = data.azurerm_client_config.this.tenant_id

#   network_acls = {
#     default_action = "Allow"
#     bypass         = "AzureServices"
#   }

#   # role_assignments = {
#   #   deployment_user_secrets = { #give the deployment user access to secrets
#   #     role_definition_id_or_name = "Key Vault Secrets Officer"
#   #     principal_id               = data.azurerm_client_config.current.object_id
#   #   }
#   #   deployment_user_keys = { #give the deployment user access to keys
#   #     role_definition_id_or_name = "Key Vault Crypto Officer"
#   #     principal_id               = data.azurerm_client_config.current.object_id
#   #   }
#   #   user_managed_identity_keys = { #give the user assigned managed identity for the disk encryption set access to keys
#   #     role_definition_id_or_name = "Key Vault Crypto Officer"
#   #     principal_id               = azurerm_user_assigned_identity.test.principal_id
#   #   }
#   # }

#   wait_for_rbac_before_key_operations = {
#     create = "60s"
#   }

#   wait_for_rbac_before_secret_operations = {
#     create = "60s"
#   }

#   tags = module.test.tags  
# }