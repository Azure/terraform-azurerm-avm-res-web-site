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

module "avm_res_web_site" {
  source = "../../"

  kind                     = "functionapp"
  location                 = azapi_resource.resource_group.location
  name                     = "${module.naming.function_app.name_unique}-default"
  os_type                  = "Windows"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  enable_telemetry         = var.enable_telemetry
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "v8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
    ip_restriction = [
      {
        action      = "Allow"
        name        = "PortalAccess"
        priority    = 1000
        service_tag = "AzurePortal"
        headers = [
          {
            x_fd_health_probe = ["1"]
          }
        ]
      }
    ]
  }
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_account_name       = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
