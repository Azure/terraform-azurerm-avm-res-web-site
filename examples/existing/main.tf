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

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body     = {}
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2024-04-01"
  body = {
    kind = "linux"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved = true
    }
  }
  tags = {
    app = "${module.naming.function_app.name_unique}-default"
  }
}

resource "azapi_resource" "storage_account" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Storage/storageAccounts@2023-05-01"
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_ZRS"
    }
    properties = {
      networkAcls = {
        defaultAction = "Allow"
        bypass        = "AzureServices"
      }
    }
  }
}

data "azapi_resource_action" "storage_keys" {
  action                 = "listKeys"
  method                 = "POST"
  resource_id            = azapi_resource.storage_account.id
  type                   = "Microsoft.Storage/storageAccounts@2023-05-01"
  response_export_values = ["keys"]
}

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-existing-resources"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

resource "azapi_resource" "application_insights" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.application_insights.name_unique}-existing-resources"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Insights/components@2020-02-02"
  body = {
    kind = "web"
    properties = {
      Application_Type    = "web"
      WorkspaceResourceId = azapi_resource.log_analytics_workspace.id
    }
  }
  response_export_values = ["properties.ConnectionString", "properties.InstrumentationKey"]
}

resource "azapi_resource" "log_analytics_workspace_staging" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-existing-resources-staging"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

resource "azapi_resource" "application_insights_staging" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.application_insights.name_unique}-existing-resources-staging"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Insights/components@2020-02-02"
  body = {
    kind = "web"
    properties = {
      Application_Type    = "web"
      WorkspaceResourceId = azapi_resource.log_analytics_workspace_staging.id
    }
  }
  response_export_values = ["properties.ConnectionString", "properties.InstrumentationKey"]
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "webapp"
  location = azapi_resource.resource_group.location
  name     = "${module.naming.function_app.name_unique}-existing-resources"
  # Uses an existing app service plan
  os_type                  = "Linux"
  resource_group_name      = azapi_resource.resource_group.name
  service_plan_resource_id = azapi_resource.service_plan.id
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azapi_resource.application_insights.output.properties.ConnectionString
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azapi_resource.application_insights.output.properties.InstrumentationKey
  }
  deployment_slots = {
    slot2 = {
      name                                           = "staging"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        # Uses existing application insights
        application_insights_connection_string = azapi_resource.application_insights_staging.output.properties.ConnectionString
        application_insights_key               = azapi_resource.application_insights_staging.output.properties.InstrumentationKey
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
  # Uses existing application insights
  enable_application_insights = false
  enable_telemetry            = var.enable_telemetry
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  # Uses an existing storage account
  storage_account_name = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.19.1"
  }
  vnet_image_pull_enabled = true
}
