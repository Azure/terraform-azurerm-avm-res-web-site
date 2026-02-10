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

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-logicapp"
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

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2024-04-01"
  body = {
    kind = "app"
    sku = {
      name = "WS1"
    }
    properties = {
      reserved = false
    }
  }
  tags = {
    app = module.naming.logic_app_workflow.name_unique
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

resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.0.0/24"]
      }
    }
  }
}

resource "azapi_resource" "subnet" {
  name      = module.naming.subnet.name_unique
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  body = {
    properties = {
      addressPrefix = "192.168.0.0/24"
    }
  }
}

resource "azapi_resource" "private_dns_zone" {
  location  = "global"
  name      = local.azurerm_private_dns_zone_resource_name
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/privateDnsZones@2024-06-01"
  body      = {}
}

resource "azapi_resource" "private_dns_zone_virtual_network_link" {
  location  = "global"
  name      = "${azapi_resource.virtual_network.name}-link"
  parent_id = azapi_resource.private_dns_zone.id
  type      = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01"
  body = {
    properties = {
      virtualNetwork = {
        id = azapi_resource.virtual_network.id
      }
      registrationEnabled = false
    }
  }
}

data "azapi_client_config" "this" {}

module "avm_res_web_site" {
  source = "../../"

  kind                     = "logicapp"
  location                 = azapi_resource.resource_group.location
  name                     = module.naming.logic_app_workflow.name_unique
  os_type                  = "Windows"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  app_settings = {
    FUNCTIONS_RUNTIME_WORKER     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~18"
  }
  application_insights = {
    workspace_resource_id = azapi_resource.log_analytics_workspace.id
  }
  enable_telemetry = var.enable_telemetry
  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azapi_resource.private_dns_zone.id]
      subnet_resource_id            = azapi_resource.subnet.id
      tags = {
        webapp = "${module.naming.logic_app_workflow.name_unique}-interfaces"
      }
    }
  }
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name = "/subscriptions/${data.azapi_client_config.this.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      principal_id               = data.azapi_client_config.this.object_id
    }
  }
  site_config = {

  }
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_account_name       = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
