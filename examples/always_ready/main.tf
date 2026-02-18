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
    kind = "functionapp"
    sku = {
      name = "FC1"
    }
    properties = {
      reserved      = true
      zoneRedundant = true
    }
  }
  tags = {
    app = "${module.naming.function_app.name_unique}-always-ready"
  }
}

resource "azapi_resource" "user_assigned_identity" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.user_assigned_identity.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
  body      = {}
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
  tags = {
    SecurityControl = "Ignore"
  }
}

resource "azapi_resource" "storage_container" {
  name      = "example-always-ready-container"
  parent_id = "${azapi_resource.storage_account.id}/blobServices/default"
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01"
  body      = {}
}

module "avm_res_web_site" {
  source = "../../"

  location                 = azapi_resource.resource_group.location
  name                     = "${module.naming.function_app.name_unique}-always-ready"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  always_ready = {
    http = {
      name           = "http"
      instance_count = 3
    }
    blob = {
      name           = "blob"
      instance_count = 3
    }
    durable = {
      name           = "durable"
      instance_count = 3
    }
  }
  enable_telemetry      = var.enable_telemetry
  fc1_runtime_name      = "node"
  fc1_runtime_version   = "20"
  function_app_uses_fc1 = true
  instance_memory_in_mb = 2048
  kind                  = "functionapp"
  managed_identities = {
    # Identities can only be used with the Standard SKU
    system_assigned = true
    user_assigned_resource_ids = [
      azapi_resource.user_assigned_identity.id
    ]
  }
  maximum_instance_count            = 100
  os_type                           = "Linux"
  public_network_access_enabled     = true
  storage_account_access_key        = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_authentication_type       = "UserAssignedIdentity"
  storage_container_endpoint        = azapi_resource.storage_container.id
  storage_container_type            = "blobContainer"
  storage_user_assigned_identity_id = azapi_resource.user_assigned_identity.id
  tags = {
    module          = "Azure/avm-res-web-site/azurerm"
    version         = "0.19.3"
    SecurityControl = "Ignore"
  }
}
