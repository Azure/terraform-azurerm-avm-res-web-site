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

module "avm_res_resources_resourcegroup" {
  source  = "Azure/avm_res_resources_resourcegroup/azurerm"
  version = "0.1.0"

  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

module "avm_res_web_serverfarm" {
  source  = "Azure/avm_res_web_serverfarm/azurerm"
  version = "0.2.0"

  enable_telemetry = var.enable_telemetry

  name                = module.naming.app_service_plan.name_unique
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location
  os_type             = "Windows"

  tags = {
    module  = "Azure/avm_res_web_serverfarm/azurerm"
    version = "0.2.0"
  }
}

# Deploying Storage Account outside of root module to avoid circular dependency for role assignment + managed identity
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
  role_assignments = {
    storage_blob_data_owner = {
      role_definition_id_or_name = "Storage Blob Data Owner"
      principal_id               = module.avm_res_web_site.identity_principal_id
    }
  }
}

# This is the module call
module "avm_res_web_site" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.11.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-mi"
  resource_group_name = module.avm_res_resources_resourcegroup.name
  location            = module.avm_res_resources_resourcegroup.resource.location

  kind                     = "functionapp"
  os_type                  = "Windows"
  service_plan_resource_id = module.avm_res_web_serverfarm.resource_id

  storage_account_name          = module.avm_res_storage_storageaccount.name
  storage_uses_managed_identity = true

  managed_identities = {
    system_assigned = true
  }

}
