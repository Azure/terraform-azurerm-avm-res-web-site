resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"
  body     = {}
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2025-03-01"
  body = {
    kind = "app"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved      = false
      zoneRedundant = true
    }
  }
  tags = {
    example = "deployment-slots-sensitive"
  }
}

module "avm_res_web_site" {
  source = "../.."

  location                 = azapi_resource.resource_group.location
  name                     = module.naming.app_service.name_unique
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  deployment_slots = {
    test = {
      name = "test"
      site_config = {
        always_on = true
        application_stack = {
          dotnet = {
            current_stack               = "dotnet"
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
    staging = {
      name = "staging"
      site_config = {
        always_on = true
        application_stack = {
          dotnet = {
            current_stack               = "dotnet"
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
    production = {
      name = "prod"
      site_config = {
        always_on = true
        application_stack = {
          dotnet = {
            current_stack               = "dotnet"
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
  }
  enable_telemetry              = var.enable_telemetry
  kind                          = "webapp"
  os_type                       = "Windows"
  public_network_access_enabled = true
  site_config = {
    application_stack = {
      dotnet = {
        current_stack               = "dotnet"
        dotnet_version              = "v8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }
  slot_app_settings = {
    staging = {
      "ASPNETCORE_ENVIRONMENT"     = "Staging"
      "DATABASE_CONNECTION_STRING" = var.staging_database_connection_string
      "THIRD_PARTY_API_KEY"        = var.staging_api_key
      "LOG_LEVEL"                  = "Debug"
      "FEATURE_FLAG_NEW_UI"        = "true"
    }
    production = {
      "ASPNETCORE_ENVIRONMENT"     = "Production"
      "DATABASE_CONNECTION_STRING" = var.production_database_connection_string
      "THIRD_PARTY_API_KEY"        = var.production_api_key
      "STORAGE_CONNECTION_STRING"  = var.production_storage_key
      "LOG_LEVEL"                  = "Warning"
      "FEATURE_FLAG_NEW_UI"        = "false"
    }
  }
  tags = {
    example         = "deployment-slots-with-sensitive-values"
    environment     = "demo"
    SecurityControl = "Ignore"
  }
}
