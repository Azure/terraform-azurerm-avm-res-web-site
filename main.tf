


resource "azurerm_windows_function_app" "this" {
  count = var.os_type == "Windows"  ? 1 : 0

  name                = var.name # calling code must supply the name
  resource_group_name = var.resource_group_name
  location            = coalesce(var.location)
  
  storage_account_name = var.storage_account_name
  storage_account_access_key  = var.storage_account_access_key
  service_plan_id = var.service_plan_resource_id

  site_config {}

}

resource "azurerm_linux_function_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = var.name # calling code must supply the name
  resource_group_name = var.resource_group_name
  location            = coalesce(var.location)
  
  storage_account_name = var.storage_account_name
  storage_account_access_key  = var.storage_account_access_key

  service_plan_id = var.service_plan_resource_id

  site_config {}

}




# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count      = var.lock.kind != "None" ? 1 : 0

  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id
  lock_level = var.lock.kind
}


