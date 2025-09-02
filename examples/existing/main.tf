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
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "P1v2"
  tags = {
    app = "${module.naming.function_app.name_unique}-default"
  }
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "Zcd .RS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-existing-resources"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "example" {
  application_type    = "web"
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.application_insights.name_unique}-existing-resources"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_log_analytics_workspace" "example_staging" {
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.log_analytics_workspace.name}-existing-resources-staging"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "example_staging" {
  application_type    = "web"
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.application_insights.name_unique}-existing-resources-staging"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example_staging.id
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "webapp"
  location = azurerm_resource_group.example.location
  name     = "${module.naming.function_app.name_unique}-existing-resources"
  # Uses an existing app service plan
  os_type                    = azurerm_service_plan.example.os_type
  resource_group_name        = azurerm_resource_group.example.name
  service_plan_resource_id   = azurerm_service_plan.example.id
  enable_telemetry           = var.enable_telemetry
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # Uses an existing storage account
  storage_account_name = azurerm_storage_account.example.name
  # Uses existing application insights
  enable_application_insights = false
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = nonsensitive(azurerm_application_insights.example.connection_string)
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = nonsensitive(azurerm_application_insights.example.instrumentation_key)
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
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.19.1"
  }
  vnet_image_pull_enabled = true

  deployment_slots = {
    slot2 = {
      name                                           = "staging"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        # Uses existing application insights
        application_insights_connection_string = nonsensitive(azurerm_application_insights.example_staging.connection_string)
        application_insights_key               = nonsensitive(azurerm_application_insights.example_staging.instrumentation_key)
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
  }
}
