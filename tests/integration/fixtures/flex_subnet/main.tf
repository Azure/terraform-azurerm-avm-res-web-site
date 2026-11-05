resource "random_id" "name" {
  byte_length = 6
}

data "azapi_client_config" "current" {}

resource "azapi_resource" "resource_group" {
  location               = var.location
  name                   = local.name
  parent_id              = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type                   = var.resource_types.resources_resource_groups
  body                   = {}
  ignore_body_changes    = length(var.ignore_body_changes.resources_resource_groups) > 0 ? var.ignore_body_changes.resources_resource_groups : null
  response_export_values = []
  retry = var.retry != null ? var.retry : {
    error_message_regex  = ["InUseSubnetCannotBeDeleted", "SubnetInUse", "ServiceAssociationLink"]
    interval_seconds     = 10
    max_interval_seconds = 60
  }
  tags = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "service_plan" {
  location  = var.location
  name      = local.name
  parent_id = azapi_resource.resource_group.id
  type      = var.resource_types.web_serverfarms
  body = {
    kind       = "functionapp"
    sku        = { name = "FC1", tier = "FlexConsumption" }
    properties = { reserved = true }
  }
  ignore_body_changes    = length(var.ignore_body_changes.web_serverfarms) > 0 ? var.ignore_body_changes.web_serverfarms : null
  response_export_values = []
  retry                  = var.retry
  tags                   = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "network" {
  location  = var.location
  name      = local.name
  parent_id = azapi_resource.resource_group.id
  type      = var.resource_types.network_virtual_networks
  body = {
    properties = {
      addressSpace = { addressPrefixes = ["10.42.0.0/16"] }
      subnets = [{
        name = "functions"
        properties = {
          addressPrefix = "10.42.0.0/24"
          delegations = [{
            name       = "functions"
            properties = { serviceName = "Microsoft.App/environments" }
          }]
        }
      }]
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_virtual_networks) > 0 ? var.ignore_body_changes.network_virtual_networks : null
  response_export_values = []
  retry                  = var.retry
  tags                   = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "storage" {
  location  = var.location
  name      = local.name
  parent_id = azapi_resource.resource_group.id
  type      = var.resource_types.storage_storage_accounts
  body = {
    kind = "StorageV2"
    sku  = { name = "Standard_LRS" }
    properties = {
      allowBlobPublicAccess    = false
      minimumTlsVersion        = "TLS1_2"
      supportsHttpsTrafficOnly = true
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.storage_storage_accounts) > 0 ? var.ignore_body_changes.storage_storage_accounts : null
  response_export_values = ["properties.primaryEndpoints.blob"]
  retry                  = var.retry
  tags                   = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "container" {
  name                   = "deployment"
  parent_id              = "${azapi_resource.storage.id}/blobServices/default"
  type                   = var.resource_types.storage_storage_accounts_blob_services_containers
  body                   = { properties = { publicAccess = "None" } }
  ignore_body_changes    = length(var.ignore_body_changes.storage_storage_accounts_blob_services_containers) > 0 ? var.ignore_body_changes.storage_storage_accounts_blob_services_containers : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

module "site" {
  source = "../../../.."

  location                      = var.location
  name                          = local.name
  parent_id                     = azapi_resource.resource_group.id
  service_plan_resource_id      = azapi_resource.service_plan.id
  delete_empty_service_plan     = false
  enable_telemetry              = false
  fc1_runtime_name              = "node"
  fc1_runtime_version           = "22"
  function_app_uses_fc1         = true
  instance_memory_in_mb         = 2048
  kind                          = "functionapp"
  managed_identities            = { system_assigned = true }
  maximum_instance_count        = 40
  os_type                       = "Linux"
  storage_account_name          = azapi_resource.storage.name
  storage_authentication_type   = "SystemAssignedIdentity"
  storage_container_endpoint    = "${azapi_resource.storage.output.properties.primaryEndpoints.blob}${azapi_resource.container.name}"
  storage_uses_managed_identity = true
  tags                          = var.tags
  virtual_network_subnet_id     = var.attach_subnet ? local.subnet_id : null

  # Keep the network dependency even after the caller stops passing its subnet.
  # Terraform must delete the app before the integration subnet during cleanup.
  depends_on = [azapi_resource.network]
}

resource "azapi_resource" "storage_role" {
  name      = uuidv5("url", "${azapi_resource.storage.id}/blob-owner/${module.site.system_assigned_mi_principal_id}")
  parent_id = azapi_resource.storage.id
  type      = var.resource_types.authorization_role_assignments
  body = {
    properties = {
      principalId      = module.site.system_assigned_mi_principal_id
      principalType    = "ServicePrincipal"
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
