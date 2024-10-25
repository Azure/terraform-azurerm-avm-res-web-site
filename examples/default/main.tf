## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
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
  version = ">= 0.3.0"
}

# module "avm_res_resources_resourcegroup" {
#   source  = "Azure/avm-res-resources-resourcegroup/azurerm"
#   version = "0.1.0"

#   location = local.azure_regions[random_integer.region_index.result]
#   name     = module.naming.resource_group.name_unique
#   tags = {
#     module  = "Azure/avm-res-resources-resourcegroup/azurerm"
#     version = "0.1.0"
#   }
# }

resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# module "avm_res_web_serverfarm" {
#   source  = "Azure/avm-res-web-serverfarm/azurerm"
#   version = "0.2.0"

#   enable_telemetry = var.enable_telemetry

#   name                = module.naming.app_service_plan.name_unique
#   resource_group_name = module.avm_res_resources_resourcegroup.name
#   location            = module.avm_res_resources_resourcegroup.resource.location
#   os_type             = "Windows"

#   tags = {
#     module  = "Azure/avm-res-web-serverfarm/azurerm"
#     version = "0.2.0"
#   }
# }

resource "azurerm_service_plan" "example" {
  name                = module.naming.app_service_plan.name_unique
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type = "Windows"
  sku_name                     = "P1v2"
  tags                         = {
    app = "${module.naming.function_app.name_unique}-default"
  }
}

# module "avm_res_storage_storageaccount" {
#   source  = "Azure/avm-res-storage-storageaccount/azurerm"
#   version = "0.2.4"

#   enable_telemetry              = var.enable_telemetry
#   name                          = module.naming.storage_account.name_unique
#   resource_group_name           = module.avm_res_resources_resourcegroup.name
#   location                      = module.avm_res_resources_resourcegroup.resource.location
#   shared_access_key_enabled     = true
#   public_network_access_enabled = true
#   network_rules = {
#     bypass         = ["AzureServices"]
#     default_action = "Allow"
#   }

#   tags = {
#     module  = "Azure/avm-res-storage-storageaccount/azurerm"
#     version = "0.2.4"
#   }

# }

resource "azurerm_storage_account" "example" {
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location

  account_tier = "Standard"
  account_replication_type = "LRS"

  network_rules {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }

}

module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.11.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-default"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind = "functionapp"

  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id

  # Uses an existing storage account
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # storage_uses_managed_identity = true

  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.11.0"
  }

}
