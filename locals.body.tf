locals {
  body = {
    kind = local.arm_kind
    properties = merge(
      {
        enabled                   = var.enabled
        httpsOnly                 = var.https_only
        serverFarmId              = var.service_plan_resource_id
        reserved                  = local.is_linux
        clientAffinityEnabled     = var.client_affinity_enabled
        clientCertEnabled         = var.client_certificate_enabled
        clientCertMode            = var.client_certificate_enabled ? var.client_certificate_mode : null
        clientCertExclusionPaths  = var.client_certificate_exclusion_paths
        publicNetworkAccess       = var.public_network_access_enabled ? "Enabled" : "Disabled"
        virtualNetworkSubnetId    = var.virtual_network_subnet_id
        keyVaultReferenceIdentity = var.key_vault_reference_identity
        siteConfig                = local.site_config_body
        outboundVnetRouting = {
          backupRestoreTraffic = var.virtual_network_backup_restore_enabled
          contentShareTraffic  = var.vnet_content_share_enabled
          imagePullTraffic     = var.vnet_image_pull_enabled
        }
      },
      var.function_app_uses_fc1 ? {
        functionAppConfig = {
          deployment = {
            storage = {
              type  = var.storage_container_type
              value = var.storage_container_endpoint
              authentication = {
                type                               = var.storage_authentication_type
                storageAccountConnectionStringName = null
                userAssignedIdentityResourceId     = var.storage_user_assigned_identity_id
              }
            }
          }
          scaleAndConcurrency = {
            alwaysReady          = length(var.always_ready) > 0 ? [for k, v in var.always_ready : { name = coalesce(v.name, k), instanceCount = v.instance_count }] : null
            maximumInstanceCount = var.maximum_instance_count
            instanceMemoryMB     = var.instance_memory_in_mb
          }
          runtime = {
            name    = var.fc1_runtime_name
            version = var.fc1_runtime_version
          }
        }
      } : {},
      local.is_function_app && !var.function_app_uses_fc1 ? {
        dailyMemoryTimeQuota = var.daily_memory_time_quota
      } : {},
    )
  }
}
