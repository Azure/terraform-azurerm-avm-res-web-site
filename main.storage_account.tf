module "avm_res_storage_storageaccount" {
  count = var.function_app_create_storage_account ? 1 : 0

  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.2.4"

  enable_telemetry = var.enable_telemetry

  name                          = var.function_app_storage_account.name
  resource_group_name           = coalesce(var.function_app_storage_account.resource_group_name, var.resource_group_name)
  location                      = coalesce(var.function_app_storage_account.location, var.location)
  account_kind                  = var.function_app_storage_account.account_kind
  account_tier                  = var.function_app_storage_account.account_tier
  account_replication_type      = var.function_app_storage_account.account_replication_type
  shared_access_key_enabled     = var.function_app_storage_account.shared_access_key_enabled
  public_network_access_enabled = var.function_app_storage_account.public_network_access_enabled
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
  tags = var.tags
}
