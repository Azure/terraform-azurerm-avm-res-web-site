# data "azurerm_service_plan" "existing" {
#   count = !var.new_app_service_plan.create ? 1 : 0

#   name = var.existing_app_service_plan.name
#   resource_group_name = var.existing_app_service_plan.resource_group_name
# }

# data "azurerm_service_plan" "new" {
#   count = var.new_app_service_plan.create ? 1 : 0

#   name = azurerm_service_plan.this[0].name
#   resource_group_name = azurerm_service_plan.this[0].resource_group_name
# }

# resource "azurerm_service_plan" "this" {
#   count = var.new_app_service_plan.create ? 1 : 0

#   name = coalesce(var.new_app_service_plan.name, "${var.name}-service-plan")
#   location = coalesce(var.new_app_service_plan.location, var.location, local.resource_group_location)
#   resource_group_name = coalesce(var.new_app_service_plan.resource_group_name, var.resource_group_name)
#   os_type = var.new_app_service_plan.os_type
#   sku_name = var.new_app_service_plan.sku_name
# }
