terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

data "azurerm_subscription" "current" {
}

data "azapi_resource_list" "example" {
  type                   = "Microsoft.Web/serverfarms@2022-03-01"
  parent_id              = data.azurerm_subscription.current.id
  response_export_values = ["*"]
}

locals {
  location_valid_skus = [
    for location in jsondecode(data.azapi_resource_list.example.output).value : location
    if contains(location.locations, var.deployment_region) &&
    location.resourceType == "serverfarms" &&
    length(location.restrictions) < 1 &&
    length(try(location.capabilities, [])) > 1
  ]

  deploy_skus = [for sku in local.location_valid_skus : sku]
}

resource "random_integer" "deploy_sku" {
  min = 0
  max = length(local.deploy_skus) - 1

}