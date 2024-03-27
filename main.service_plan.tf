resource "azurerm_service_plan" "this" {
  count = var.create_service_plan ? 1 : 0

  location                   = coalesce(var.new_service_plan.location, var.location)
  name                       = coalesce(var.new_service_plan.name, "${var.name}-asp")
  os_type                    = var.os_type
  resource_group_name        = coalesce(var.new_service_plan.resource_group_name, var.resource_group_name)
  sku_name                   = var.new_service_plan.sku_name
  app_service_environment_id = var.new_service_plan.app_service_environment_resource_id
  tags                       = var.tags
}
