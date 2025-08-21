resource "azurerm_logic_app_standard" "this" {
  count = var.kind == "logicapp" ? 1 : 0

  app_service_plan_id                      = var.service_plan_resource_id
  location                                 = var.location
  name                                     = var.name
  resource_group_name                      = var.resource_group_name
  storage_account_access_key               = var.storage_account_access_key
  storage_account_name                     = var.storage_account_name
  app_settings                             = var.enable_application_insights ? merge({ "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.this[0].instrumentation_key }, var.app_settings) : var.app_settings
  bundle_version                           = var.bundle_version
  client_affinity_enabled                  = var.client_affinity_enabled
  client_certificate_mode                  = var.client_certificate_mode
  enabled                                  = var.enabled
  ftp_publish_basic_authentication_enabled = var.ftp_publish_basic_authentication_enabled
  https_only                               = var.https_only
  public_network_access                    = var.public_network_access_enabled == true ? "Enabled" : "Disabled"
  scm_publish_basic_authentication_enabled = var.scm_publish_basic_authentication_enabled
  storage_account_share_name               = var.storage_account_share_name
  tags                                     = var.tags
  use_extension_bundle                     = var.use_extension_bundle
  version                                  = var.logic_app_runtime_version
  virtual_network_subnet_id                = var.virtual_network_subnet_id
  vnet_content_share_enabled               = var.vnet_content_share_enabled

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  site_config {
    always_on                        = var.site_config.always_on
    app_scale_limit                  = var.site_config.app_scale_limit
    auto_swap_slot_name              = var.site_config.auto_swap_slot_name
    dotnet_framework_version         = var.site_config.dotnet_framework_version
    elastic_instance_minimum         = var.site_config.elastic_instance_minimum
    ftps_state                       = var.site_config.ftps_state
    health_check_path                = var.site_config.health_check_path
    http2_enabled                    = var.site_config.http2_enabled
    linux_fx_version                 = var.site_config.linux_fx_version
    min_tls_version                  = var.site_config.minimum_tls_version != "1.0" && var.site_config.minimum_tls_version != "1.1" ? "1.2" : var.site_config.minimum_tls_version # Does not yet support `1.3`
    pre_warmed_instance_count        = var.site_config.pre_warmed_instance_count
    runtime_scale_monitoring_enabled = var.site_config.runtime_scale_monitoring_enabled
    scm_min_tls_version              = var.site_config.scm_minimum_tls_version
    scm_type                         = var.site_config.scm_type
    scm_use_main_ip_restriction      = var.site_config.scm_use_main_ip_restriction
    use_32_bit_worker_process        = var.site_config.use_32_bit_worker
    vnet_route_all_enabled           = var.site_config.vnet_route_all_enabled
    websockets_enabled               = var.site_config.websockets_enabled

    dynamic "cors" {
      for_each = var.site_config.cors

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
    dynamic "ip_restriction" {
      for_each = var.site_config.ip_restriction

      content {
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id

        dynamic "headers" {
          for_each = ip_restriction.value.headers

          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }
    dynamic "scm_ip_restriction" {
      # one or more scm_ip_restriction blocks
      for_each = var.site_config.scm_ip_restriction

      content {
        action                    = scm_ip_restriction.value.action
        ip_address                = scm_ip_restriction.value.ip_address
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers

          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }
  }
}
