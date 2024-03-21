# resource "azurerm_storage_account" "this" {
#   count = var.new_storage_account.create ? 1 : 0

#   name                          = var.storage_account.name
#   resource_group_name           = coalesce(var.storage_account.resource_group_name, var.resource_group_name)
#   location = var.location
#   account_tier = "Standard"
#   account_replication_type = "LRS"
# }


module "avm_res_storage_storageaccount" {
  count = var.function_app_create_storage_account ? 1 : 0

  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.1.1"

  name                          = var.function_app_storage_account.name
  resource_group_name           = coalesce(var.function_app_storage_account.resource_group_name, var.resource_group_name)
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
  tags = var.tags
}
