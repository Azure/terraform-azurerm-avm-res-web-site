run "valid_linux_webapp" {
  command = plan

  variables {
    app_name              = "myapp-test-linux-${substr(uuid(), 0, 5)}"
    resource_group_name   = "rg-test-webapp"
    create_resource_group = true
    location              = "East US"
    os_type               = "Linux"
    sku_name              = "P1v2"
  }

  assert {
    condition     = length(azurerm_service_plan.asp) == 1
    error_message = "App Service Plan was not created."
  }

  assert {
    condition     = length(azurerm_linux_web_app.app) == 1
    error_message = "Linux Web App was not created."
  }
}

run "valid_windows_webapp" {
  command = plan

  variables {
    app_name              = "myapp-test-win-${substr(uuid(), 0, 5)}"
    resource_group_name   = "rg-test-webapp-win"
    create_resource_group = true
    location              = "East US"
    os_type               = "Windows"
    sku_name              = "P1v2"
  }

  assert {
    condition     = length(azurerm_windows_web_app.app) == 1
    error_message = "Windows Web App was not created."
  }
}
