module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.11.0"

  is_recommended = true
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body     = {}
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2024-04-01"
  body = {
    kind = "app"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved = false
    }
  }
  tags = {
    app = module.naming.function_app.name_unique
  }
}

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "${module.naming.log_analytics_workspace.name}-production"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

module "avm_res_web_site" {
  source = "../../"

  kind                     = "webapp"
  location                 = azapi_resource.resource_group.location
  name                     = module.naming.app_service.name_unique
  os_type                  = "Windows"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    workspace_resource_id = azapi_resource.log_analytics_workspace.id
  }
  auth_settings_v2 = {
    default = {
      auth_enabled     = true
      default_provider = "okta"
      custom_oidc_v2 = {
        default = {
          name                          = "example_oidc_provider"
          client_id                     = "your-client-id"
          openid_configuration_endpoint = "https://test-config-endpoint.com/.well-known/openid-configuration"
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  site_config = {

  }
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
