## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.0"
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
  version = "0.4.2"
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
    example = "deployment-slots-sensitive"
  }
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = "${module.naming.storage_account.name_unique}sens"
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

# This is the module call with deployment slots containing sensitive values
module "avm_res_web_site" {
  source = "../.."

  enable_telemetry = var.enable_telemetry

  # Basic configuration
  kind                     = "webapp"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.app_service.name_unique
  os_type                  = "Windows"
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id

  # Site configuration
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "v8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }

  # Deployment slots with SENSITIVE values
  # This demonstrates the fix for issue #255
  # The nonsensitive() wrapper allows us to use sensitive values in app_settings
  deployment_slots = {
    # Staging slot with sensitive database connection and API key
    staging = {
      name = "staging"

      # These app_settings contain SENSITIVE values
      # Before the fix, this would cause: "Error: Invalid for_each argument"
      # After the fix, it works correctly
      app_settings = {
        "ASPNETCORE_ENVIRONMENT"     = "Staging"
        "DATABASE_CONNECTION_STRING" = sensitive(var.staging_database_connection_string)
        "THIRD_PARTY_API_KEY"        = sensitive(var.staging_api_key)
        "LOG_LEVEL"                  = "Debug"
        "FEATURE_FLAG_NEW_UI"        = "true"
      }

      site_config = {
        always_on = true
        application_stack = {
          dotnet = {
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }

    # Production slot with different sensitive values
    production = {
      name = "production"

      # Production has its own set of sensitive values
      app_settings = {
        "ASPNETCORE_ENVIRONMENT"     = "Production"
        "DATABASE_CONNECTION_STRING" = sensitive(var.production_database_connection_string)
        "THIRD_PARTY_API_KEY"        = sensitive(var.production_api_key)
        "STORAGE_CONNECTION_STRING"  = sensitive(var.production_storage_key)
        "LOG_LEVEL"                  = "Warning"
        "FEATURE_FLAG_NEW_UI"        = "false"
      }

      site_config = {
        always_on = true
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

  tags = {
    example     = "deployment-slots-with-sensitive-values"
    environment = "demo"
  }
}
