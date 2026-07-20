terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.app_name}-asp"
  location            = var.location
  resource_group_name = local.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "app" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.app_name
  location            = var.location
  resource_group_name = local.resource_group_name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = true
  }

  app_settings = var.app_settings

  identity {
    type = "SystemAssigned"
  }

  # IMPORTANT: Prevent drift from external configuration (e.g. CI/CD)
  lifecycle {
    ignore_changes = [
      app_settings,
      site_config,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  tags = var.tags
}

resource "azurerm_windows_web_app" "app" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.app_name
  location            = var.location
  resource_group_name = local.resource_group_name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = true
  }

  app_settings = var.app_settings

  identity {
    type = "SystemAssigned"
  }

  # IMPORTANT: Prevent drift from external configuration (e.g. CI/CD)
  lifecycle {
    ignore_changes = [
      app_settings,
      site_config,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  tags = var.tags
}
