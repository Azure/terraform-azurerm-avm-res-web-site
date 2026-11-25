resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

data "azapi_client_config" "current" {}

module "naming" {
  source  = "Azure/avm-utl-naming/azure"
  version = "0.2.0"
}

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"
  body     = {}
  tags = {
    SecurityControl = "Ignore" # Useful for test environments
  }
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2025-03-01"
  body = {
    kind = "elastic"
    sku = {
      name = "WS1"
    }
    properties = {
      reserved      = false
      zoneRedundant = false
    }
  }
  tags = {
    app = module.naming.logic_app_workflow.name_unique
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

resource "azapi_resource" "user_assigned_identity" {
  location               = azapi_resource.resource_group.location
  name                   = module.naming.user_assigned_identity.name_unique
  parent_id              = azapi_resource.resource_group.id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
  body                   = {}
  response_export_values = ["properties.principalId"]
}

resource "random_uuid" "role_assignment" {
  for_each = local.storage_role_definition_ids
}

resource "azapi_resource" "role_assignment" {
  for_each = local.storage_role_definition_ids

  name      = random_uuid.role_assignment[each.key].result
  parent_id = azapi_resource.storage_account.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${each.value}"
      principalId      = azapi_resource.user_assigned_identity.output.properties.principalId
      principalType    = "ServicePrincipal"
    }
  }
}

module "avm_res_web_site" {
  source = "../../"

  location                 = azapi_resource.resource_group.location
  name                     = module.naming.logic_app_workflow.name_unique
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  enable_telemetry         = var.enable_telemetry
  kind                     = "logicapp"
  managed_identities = {
    user_assigned_resource_ids = [azapi_resource.user_assigned_identity.id]
  }
  os_type = "Windows"
  site_config = {
    runtime_scale_monitoring_enabled = true
  }
  storage_account_name          = azapi_resource.storage_account.name
  storage_uses_managed_identity = true
}
