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
    kind = "app"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved = false
    }
  }
  tags = {
    app = module.naming.app_service.name_unique
  }
}

resource "azapi_resource" "log_analytics_workspace_production" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-production"
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

resource "azapi_resource" "log_analytics_workspace_development" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-development-env"
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
    properties = {}
  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}

data "azapi_resource_action" "storage_keys" {
  action                 = "listKeys"
  method                 = "POST"
  resource_id            = azapi_resource.storage_account.id
  type                   = "Microsoft.Storage/storageAccounts@2023-05-01"
  response_export_values = ["keys"]
}

resource "azapi_resource" "storage_share_content" {
  name      = "app-content"
  parent_id = "${azapi_resource.storage_account.id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01"
  body = {
    properties = {
      shareQuota = 10
    }
  }
}

resource "azapi_resource" "storage_share_dev_content" {
  name      = "dev-content"
  parent_id = "${azapi_resource.storage_account.id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01"
  body = {
    properties = {
      shareQuota = 10
    }
  }
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "webapp"
  location = azapi_resource.resource_group.location
  name     = module.naming.app_service.name_unique
  # Uses an existing app service plan
  os_type                  = "Windows"
  resource_group_name      = azapi_resource.resource_group.name
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    workspace_resource_id = azapi_resource.log_analytics_workspace_production.id
  }
  deployment_slots = {
    slot1 = {
      name = "development-env"
      site_config = {
        slot_application_insights_object_key = "development" # This is the key for the slot application insights mapping
        application_stack = {
          dotnet = {
            current_stack               = "dotnet"
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
      storage_shares_to_mount = {
        dev_content = {
          name         = "dev-content"
          account_name = azapi_resource.storage_account.name
          # access_key   = ...
          share_name = azapi_resource.storage_share_content.name
          mount_path = "/mounts/${azapi_resource.storage_share_dev_content.name}"
        }
      }

    }
  }
  enable_telemetry = var.enable_telemetry
  # Creates application insights for slot
  slot_application_insights = {
    development = {
      name                  = "${module.naming.application_insights.name_unique}-development-env"
      workspace_resource_id = azapi_resource.log_analytics_workspace_development.id
      inherit_tags          = true
    }
  }
  slots_storage_shares_to_mount_sensitive_values = {
    dev_content = data.azapi_resource_action.storage_keys.output.keys[0].value
  }
  storage_shares_to_mount = {
    content = {
      name         = "content"
      account_name = azapi_resource.storage_account.name
      access_key   = data.azapi_resource_action.storage_keys.output.keys[0].value
      share_name   = azapi_resource.storage_share_content.name
      mount_path   = "/mounts/${azapi_resource.storage_share_content.name}"
    }
  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
