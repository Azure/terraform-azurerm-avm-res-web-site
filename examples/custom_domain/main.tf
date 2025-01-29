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
    app = "${module.naming.function_app.name_unique}-custom-domain"
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

# Use data object to reference an existing Key Vault and stored certificate
/*
data "azurerm_key_vault" "existing_keyvault" {
  name                = "<keyvault_name>"
  resource_group_name = "<keyvault_resource_group>"
}
# /*
data "azurerm_key_vault_secret" "stored_certificate" {
  key_vault_id = data.azurerm_key_vault.existing_keyvault.id
  name         = "<certificate_name>"
}
*/


# This is the module call
module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.14.2"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-default"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind = "functionapp"

  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id

  # Uses an existing storage account
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # storage_uses_managed_identity = true

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

  /*

  custom_domains = {
    # Allows for the configuration of custom domains for the Function App
    # If not already set, the module allows for the creation of TXT and CNAME records

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
      hostname            = "${module.naming.function_app.name_unique}-custom-domain.<zone_name>"
      resource_group_name = azurerm_resource_group.example.name
      ssl_state           = "SniEnabled"
      thumbprint_key      = "production" # Currently the key of the custom domain
    },
    qa = {
      slot_as_target = true

      zone_resource_group_name = "<zone_resource_group_name>"

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

      create_certificate   = true
      certificate_name     = "${module.naming.function_app.name_unique}-${data.azurerm_key_vault_secret.stored_certificate.name}"
      certificate_location = azurerm_resource_group.example.location
      pfx_blob             = data.azurerm_key_vault_secret.stored_certificate.value

      app_service_slot_key = "qa"
      hostname             = "${module.naming.function_app.name_unique}-qa.<zone_name>"
      ssl_state            = "SniEnabled"
      thumbprint_key       = "production"
    }

  }

  */

  tags = {
    environment = "dev-tf"
  }

}