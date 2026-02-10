module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.11.0"

  is_recommended = true
}

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

resource "azapi_resource" "log_analytics_workspace_development" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-development-env"
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
  type                   = "Microsoft.Storage/storageAccounts@2025-01-01"
  response_export_values = ["keys"]
}

resource "azapi_resource" "storage_share_content" {
  name      = "app-content"
  parent_id = "${azapi_resource.storage_account.id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01"
  body = {
    properties = {
      shareQuota = 10
    }
  }
}

resource "azapi_resource" "storage_share_dev_content" {
  name      = "dev-content"
  parent_id = "${azapi_resource.storage_account.id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01"
  body = {
    properties = {
      shareQuota = 10
    }
  }
}

module "avm_res_web_site" {
  source = "../../"

  location                 = azapi_resource.resource_group.location
  name                     = module.naming.app_service.name_unique
  parent_id                = azapi_resource.resource_group.id
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
          share_name   = azapi_resource.storage_share_content.name
          mount_path   = "/mounts/${azapi_resource.storage_share_dev_content.name}"
        }
      }

    }
  }
  enable_telemetry = var.enable_telemetry
  kind             = "webapp"
  os_type          = "Windows"
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
