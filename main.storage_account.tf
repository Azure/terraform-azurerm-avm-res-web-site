# data "azurerm_storage_account" "existing" {
#   name = !var.new_storage_account.create ? var.existing_storage_account.resource_group_name : null
#   resource_group_name = !var.new_storage_account.create ? var.existing_storage_account.resource_group_name : null
# }

# resource "azurerm_storage_account" "this" {
#   count = var.new_storage_account.create ? 1 : 0

#   name = coalesce(var.new_storage_account.name, "${var.name}-storage")
#   location = coalesce(var.new_storage_account.location, var.location, local.resource_group_location)
#   resource_group_name = coalesce(var.new_storage_account.resource_group_name, var.resource_group_name)
#   account_tier = var.new_storage_account.account_tier
#   account_replication_type = var.new_storage_account.account_replication_type
# }