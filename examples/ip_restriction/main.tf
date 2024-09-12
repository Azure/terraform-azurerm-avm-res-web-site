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

# This is required for resource modules
module "avm_res_resources_resourcegroup" {
  source  = "Azure/avm_res_resources_resourcegroup/azurerm"
  version = "0.1.0"

  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  tags = {
    module  = "Azure/avm_res_resources_resourcegroup/azurerm"
    version = "0.1.0"
  }
}

module "avm_res_web_serverfarm" {
  source  = "Azure/avm_res_web_serverfarm/azurerm"
  version = "0.2.0"

  enable_telemetry = var.enable_telemetry

  name                = module.naming.app_service_plan.name_unique
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location
  os_type             = "Linux"

  # Remove before publishing to registry
  zone_balancing_enabled = false

  tags = {
    module  = "Azure/avm_res_web_serverfarm/azurerm"
    version = "0.2.0"
  }
}

module "avm_res_storage_storageaccount" {
  source  = "Azure/avm_res_storage_storageaccount/azurerm"
  version = "0.2.4"

  enable_telemetry              = var.enable_telemetry
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = module.avm_res_resources_resourcegroup.name
  location                      = module.avm_res_resources_resourcegroup.resource.location
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }

  # Remove before publishing to registry
  account_replication_type = "LRS"

  tags = {
    module  = "Azure/avm_res_storage_storageaccount/azurerm"
    version = "0.2.4"
  }

}

module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.11.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-restricted"
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location

  kind = "functionapp"

  # Uses an existing app service plan
  os_type                  = module.avm_res_web_serverfarm.resource.os_type
  service_plan_resource_id = module.avm_res_web_serverfarm.resource_id

  # Uses an existing storage account
  storage_account_name       = module.avm_res_storage_storageaccount.name
  storage_account_access_key = module.avm_res_storage_storageaccount.resource.primary_access_key
  # storage_uses_managed_identity = true

  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.11.0"
  }

  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
    ip_restriction = {
      test = {
        action      = "Allow"
        name        = "PortalAccess"
        priority    = 1000
        service_tag = "AzurePortal"
      }
    }
  }

}
