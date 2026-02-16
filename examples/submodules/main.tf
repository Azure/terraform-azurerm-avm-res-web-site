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
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"
  body     = {}
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2025-03-01"
  body = {
    kind = "linux"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved      = true
      zoneRedundant = true
    }
  }
  tags = {
    app = "${module.naming.function_app.name_unique}-submodules"
  }
}

resource "azapi_resource" "storage_account" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Storage/storageAccounts@2025-01-01"
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_ZRS"
    }
    properties = {
      networkAcls = {
        defaultAction = "Allow"
        bypass        = "AzureServices"
      }
    }
  }
}

# Create the site with minimal configuration using the root module
module "avm_res_web_site" {
  source = "../../"

  location                    = azapi_resource.resource_group.location
  name                        = "${module.naming.function_app.name_unique}-submodules"
  parent_id                   = azapi_resource.resource_group.id
  service_plan_resource_id    = azapi_resource.service_plan.id
  enable_application_insights = false
  enable_telemetry            = var.enable_telemetry
  kind                        = "webapp"
  os_type                     = "Linux"
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }
  storage_account_access_key = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_account_name       = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    example = "submodules"
  }
}

# Use the config_appsettings submodule independently
module "appsettings" {
  source = "../../modules/config_appsettings"

  app_settings = {
    "MY_CUSTOM_SETTING" = "my-custom-value"
    "ENVIRONMENT"       = "production"
  }
  parent_id = module.avm_res_web_site.resource_id
}

# Use the config_connectionstrings submodule independently
module "connectionstrings" {
  source = "../../modules/config_connectionstrings"

  connection_strings = {
    "primary_db" = {
      name  = "PrimaryDatabase"
      type  = "SQLAzure"
      value = "Server=tcp:myserver.database.windows.net;Database=mydb;"
    }
  }
  parent_id = module.avm_res_web_site.resource_id
}

# Use the publishing_credential_policy submodule to disable FTP basic auth
module "ftp_publishing_credential_policy" {
  source = "../../modules/publishing_credential_policy"

  name      = "ftp"
  parent_id = module.avm_res_web_site.resource_id
  allow     = false
}

# Use the publishing_credential_policy submodule to disable SCM basic auth
module "scm_publishing_credential_policy" {
  source = "../../modules/publishing_credential_policy"

  name      = "scm"
  parent_id = module.avm_res_web_site.resource_id
  allow     = false
}

# Use the config_logs submodule independently
module "logs" {
  source = "../../modules/config_logs"

  parent_id = module.avm_res_web_site.resource_id
  application_logs = {
    file_system_level = "Warning"
  }
  detailed_error_messages = true
  failed_request_tracing  = true
  http_logs = {
    file_system = {
      retention_in_days = 7
      retention_in_mb   = 35
    }
  }
}
