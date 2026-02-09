## Section to provide a random Azure region for the resource group
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.0"
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

data "azapi_client_config" "current" {}

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
  response_export_values = [
    "properties.primaryEndpoints",
    "listKeys",
  ]
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

  kind     = "functionapp"
  location = azapi_resource.resource_group.location
  name     = "${module.naming.function_app.name_unique}-default"
  # Uses an existing app service plan
  os_type                    = "Windows"
  resource_group_name        = azapi_resource.resource_group.name
  service_plan_resource_id   = azapi_resource.service_plan.id
  enable_telemetry           = var.enable_telemetry
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  # Uses an existing storage account
  storage_account_name = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.18.0"
  }
  vnet_image_pull_enabled = true
}
