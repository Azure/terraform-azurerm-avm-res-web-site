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

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-zip"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2025-02-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2025-03-01"
  body = {
    kind = "linux"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved      = true
      zoneRedundant = true
    }
  }
  tags = {
    app = module.naming.function_app.name_unique
  }
}

resource "azapi_resource" "storage_account" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Storage/storageAccounts@2025-01-01"
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

module "avm_res_web_site" {
  source = "../../"

  location                 = azapi_resource.resource_group.location
  name                     = module.naming.function_app.name_unique
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    workspace_resource_id = azapi_resource.log_analytics_workspace.id
  }
  enable_telemetry = var.enable_telemetry
  kind             = "functionapp"
  os_type          = "Linux"
  site_config = {
    application_stack = {
      python = {
        python_version = "3.11"
      }
    }
  }
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_account_name       = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
