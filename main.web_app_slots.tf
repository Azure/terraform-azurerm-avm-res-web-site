resource "azurerm_windows_web_app_slot" "this" {
  for_each = { for slot, slot_values in var.deployment_slots : slot => slot_values if var.kind == "webapp" && var.os_type == "Windows" && var.deployment_slots != null }

  app_service_id                                 = azurerm_windows_web_app.this[0].id
  name                                           = coalesce(each.value.name, each.key)
  app_settings                                   = var.enable_application_insights ? merge({ "APPLICATIONINSIGHTS_CONNECTION_STRING" = (each.value.site_config.slot_application_insights_object_key != null ? coalesce(each.value.site_config.application_insights_connection_string, azurerm_application_insights.slot[each.value.site_config.slot_application_insights_object_key].connection_string, azurerm_application_insights.this[0].connection_string) : coalesce(each.value.site_config.application_insights_connection_string, azurerm_application_insights.this[0].connection_string)) }, { "APPINSIGHTS_INSTRUMENTATIONKEY" = (each.value.site_config.slot_application_insights_object_key != null ? coalesce(each.value.site_config.application_insights_key, azurerm_application_insights.slot[each.value.site_config.slot_application_insights_object_key].instrumentation_key, azurerm_application_insights.this[0].instrumentation_key) : coalesce(each.value.site_config.application_insights_key, azurerm_application_insights.this[0].instrumentation_key)) }, each.value.app_settings) : each.value.app_settings
  client_affinity_enabled                        = each.value.client_affinity_enabled
  client_certificate_enabled                     = each.value.client_certificate_enabled
  client_certificate_exclusion_paths             = each.value.client_certificate_exclusion_paths
  client_certificate_mode                        = each.value.client_certificate_mode
  enabled                                        = each.value.enabled
  ftp_publish_basic_authentication_enabled       = each.value.site_config.ftps_state == "Disabled" ? false : each.value.ftp_publish_basic_authentication_enabled
  https_only                                     = each.value.https_only
  key_vault_reference_identity_id                = each.value.key_vault_reference_identity_id
  public_network_access_enabled                  = each.value.public_network_access_enabled
  service_plan_id                                = each.value.service_plan_id
  tags                                           = each.value.tags
  virtual_network_subnet_id                      = each.value.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = each.value.site_config.ftps_state == "Disabled" ? false : each.value.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = each.value.zip_deploy_file

  site_config {
    always_on                                     = each.value.site_config.always_on
    api_definition_url                            = each.value.site_config.api_definition_url
    api_management_api_id                         = each.value.site_config.api_management_api_id
    app_command_line                              = each.value.site_config.app_command_line
    container_registry_managed_identity_client_id = each.value.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = each.value.site_config.container_registry_use_managed_identity
    default_documents                             = each.value.site_config.default_documents
    ftps_state                                    = each.value.site_config.ftps_state
    health_check_eviction_time_in_min             = each.value.site_config.health_check_eviction_time_in_min
    health_check_path                             = each.value.site_config.health_check_path
    http2_enabled                                 = each.value.site_config.http2_enabled
    ip_restriction_default_action                 = each.value.site_config.ip_restriction_default_action
    load_balancing_mode                           = each.value.site_config.load_balancing_mode
    managed_pipeline_mode                         = each.value.site_config.managed_pipeline_mode
    minimum_tls_version                           = each.value.site_config.minimum_tls_version
    remote_debugging_enabled                      = each.value.site_config.remote_debugging_enabled
    remote_debugging_version                      = each.value.site_config.remote_debugging_version
    scm_ip_restriction_default_action             = each.value.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = each.value.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = each.value.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                             = each.value.site_config.use_32_bit_worker
    vnet_route_all_enabled                        = each.value.site_config.vnet_route_all_enabled
    websockets_enabled                            = each.value.site_config.websockets_enabled
    worker_count                                  = each.value.site_config.worker_count

    dynamic "application_stack" {
      for_each = each.value.site_config.application_stack

      content {
        current_stack                = application_stack.value.current_stack
        docker_image_name            = application_stack.value.docker_image_name
        docker_registry_password     = application_stack.value.docker_registry_password
        docker_registry_url          = application_stack.value.docker_registry_url
        docker_registry_username     = application_stack.value.docker_registry_username
        dotnet_core_version          = application_stack.value.current_stack == "dotnetcore" ? application_stack.value.dotnet_core_version : null
        dotnet_version               = application_stack.value.current_stack == "dotnet" ? application_stack.value.dotnet_version : null
        java_embedded_server_enabled = application_stack.value.java_embedded_server_enabled != null ? application_stack.value.java_embedded_server_enabled : null
        java_version                 = application_stack.value.current_stack == "java" ? application_stack.value.java_version : null
        node_version                 = application_stack.value.current_stack == "node" ? application_stack.value.node_version : null
        php_version                  = application_stack.value.current_stack == "php" ? application_stack.value.php_version : null
        python                       = application_stack.value.current_stack == "python" ? application_stack.value.python : null
        tomcat_version               = application_stack.value.tomcat_version != null ? application_stack.value.tomcat_version : null
      }
    }
    dynamic "auto_heal_setting" {
      for_each = each.value.auto_heal_setting

      content {
        action {
          action_type                    = auto_heal_setting.value.action.action_type
          minimum_process_execution_time = auto_heal_setting.value.action.minimum_process_execution_time
        }
        trigger {
          private_memory_kb = auto_heal_setting.value.trigger.private_memory_kb

          dynamic "requests" {
            for_each = auto_heal_setting.value.trigger.requests

            content {
              count    = requests.value.trigger.requests.count
              interval = requests.value.trigger.requests.interval
            }
          }
          dynamic "slow_request" {
            for_each = auto_heal_setting.value.trigger.slow_request

            content {
              count      = slow_request.value.count
              interval   = slow_request.value.interval
              time_taken = slow_request.value.time_taken
            }
          }
          dynamic "slow_request_with_path" {
            for_each = auto_heal_setting.value.trigger.slow_request_with_path

            content {
              count      = slow_request_with_path.value.count
              interval   = slow_request_with_path.value.interval
              time_taken = slow_request_with_path.value.time_taken
              path       = slow_request_with_path.value.path
            }
          }
          dynamic "status_code" {
            for_each = auto_heal_setting.value.trigger.status_code

            content {
              count             = status_code.value.count
              interval          = status_code.value.interval
              status_code_range = status_code.value.status_code_range
              path              = status_code.value.path
              sub_status        = status_code.value.sub_status
              win32_status_code = status_code.value.win32_status_code
            }
          }
        }
      }
    }
    dynamic "cors" {
      for_each = each.value.site_config.cors

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
    dynamic "ip_restriction" {
      for_each = each.value.site_config.ip_restriction

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
      for_each = each.value.site_config.scm_ip_restriction

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
    dynamic "virtual_application" {
      for_each = each.value.site_config.virtual_application

      content {
        physical_path = virtual_application.value.physical_path
        preload       = virtual_application.value.preload_enabled
        virtual_path  = virtual_application.value.virtual_path

        dynamic "virtual_directory" {
          for_each = virtual_application.value.virtual_directory

          content {
            physical_path = virtual_directory.value.physical_path
            virtual_path  = virtual_directory.value.virtual_path
          }
        }
      }
    }
  }
  dynamic "auth_settings" {
    for_each = each.value.auth_settings

    content {
      enabled                        = auth_settings.value.enabled
      additional_login_parameters    = auth_settings.value.additional_login_parameters
      allowed_external_redirect_urls = auth_settings.value.allowed_external_redirect_urls
      default_provider               = auth_settings.value.default_provider
      issuer                         = auth_settings.value.issuer
      runtime_version                = auth_settings.value.runtime_version
      token_refresh_extension_hours  = auth_settings.value.token_refresh_extension_hours
      token_store_enabled            = auth_settings.value.token_store_enabled
      unauthenticated_client_action  = auth_settings.value.unauthenticated_client_action

      dynamic "active_directory" {
        for_each = auth_settings.value.active_directory

        content {
          client_id                  = active_directory.value.client_id
          allowed_audiences          = active_directory.value.allowed_audiences
          client_secret              = active_directory.value.client_secret
          client_secret_setting_name = active_directory.value.client_secret_setting_name
        }
      }
      dynamic "facebook" {
        for_each = auth_settings.value.facebook

        content {
          app_id                  = facebook.value.app_id
          app_secret              = facebook.value.app_secret
          app_secret_setting_name = facebook.value.app_secret_setting_name
          oauth_scopes            = facebook.value.oauth_scopes
        }
      }
      dynamic "github" {
        for_each = auth_settings.value.github

        content {
          client_id                  = github.value.client_id
          client_secret              = github.value.client_secret
          client_secret_setting_name = github.value.client_secret_setting_name
          oauth_scopes               = github.value.oauth_scopes
        }
      }
      dynamic "google" {
        for_each = auth_settings.value.google

        content {
          client_id                  = google.value.client_id
          client_secret              = google.value.client_secret
          client_secret_setting_name = google.value.client_secret_setting_name
          oauth_scopes               = google.value.oauth_scopes
        }
      }
      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft

        content {
          client_id                  = microsoft.value.client_id
          client_secret              = microsoft.value.client_secret
          client_secret_setting_name = microsoft.value.client_secret_setting_name
          oauth_scopes               = microsoft.value.oauth_scopes
        }
      }
      dynamic "twitter" {
        for_each = auth_settings.value.twitter

        content {
          consumer_key                 = twitter.value.consumer_key
          consumer_secret              = twitter.value.consumer_secret
          consumer_secret_setting_name = twitter.value.consumer_secret_setting_name
        }
      }
    }
  }
  dynamic "auth_settings_v2" {
    for_each = each.value.auth_settings_v2

    content {
      auth_enabled                            = auth_settings_v2.value.auth_enabled
      config_file_path                        = auth_settings_v2.value.config_file_path
      default_provider                        = auth_settings_v2.value.default_provider
      excluded_paths                          = auth_settings_v2.value.excluded_paths
      forward_proxy_convention                = auth_settings_v2.value.forward_proxy_convention
      forward_proxy_custom_host_header_name   = auth_settings_v2.value.forward_proxy_custom_host_header_name
      forward_proxy_custom_scheme_header_name = auth_settings_v2.value.forward_proxy_custom_scheme_header_name
      http_route_api_prefix                   = auth_settings_v2.value.http_route_api_prefix
      require_authentication                  = auth_settings_v2.value.require_authentication
      require_https                           = auth_settings_v2.value.require_https
      runtime_version                         = auth_settings_v2.value.runtime_version
      unauthenticated_action                  = auth_settings_v2.value.unauthenticated_action

      dynamic "login" {
        for_each = auth_settings_v2.value.login

        content {
          allowed_external_redirect_urls    = login.value.allowed_external_redirect_urls
          cookie_expiration_convention      = login.value.cookie_expiration_convention
          cookie_expiration_time            = login.value.cookie_expiration_time
          logout_endpoint                   = login.value.logout_endpoint
          nonce_expiration_time             = login.value.nonce_expiration_time
          preserve_url_fragments_for_logins = login.value.preserve_url_fragments_for_logins
          token_refresh_extension_time      = login.value.token_refresh_extension_time
          token_store_enabled               = login.value.token_store_enabled
          token_store_path                  = login.value.token_store_path
          token_store_sas_setting_name      = login.value.token_store_sas_setting_name
          validate_nonce                    = login.value.validate_nonce
        }
      }
      dynamic "active_directory_v2" {
        for_each = auth_settings_v2.value.active_directory_v2

        content {
          client_id                            = active_directory_v2.value.client_id
          tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
          allowed_applications                 = active_directory_v2.value.allowed_applications
          allowed_audiences                    = active_directory_v2.value.allowed_audiences
          allowed_groups                       = active_directory_v2.value.allowed_groups
          allowed_identities                   = active_directory_v2.value.allowed_identities
          client_secret_certificate_thumbprint = active_directory_v2.value.client_secret_certificate_thumbprint
          client_secret_setting_name           = active_directory_v2.value.client_secret_setting_name
          jwt_allowed_client_applications      = active_directory_v2.value.jwt_allowed_client_applications
          jwt_allowed_groups                   = active_directory_v2.value.jwt_allowed_groups
          login_parameters                     = active_directory_v2.value.login_parameters
          www_authentication_disabled          = active_directory_v2.value.www_authentication_disabled
        }
      }
      dynamic "apple_v2" {
        for_each = auth_settings_v2.value.apple_v2

        content {
          client_id                  = apple_v2.value.client_id
          client_secret_setting_name = apple_v2.value.client_secret_setting_name
          login_scopes               = apple_v2.value.login_scopes
        }
      }
      dynamic "azure_static_web_app_v2" {
        for_each = auth_settings_v2.value.azure_static_web_app_v2

        content {
          client_id = azure_static_web_app_v2.value.client_id
        }
      }
      dynamic "custom_oidc_v2" {
        for_each = auth_settings_v2.value.custom_oidc_v2

        content {
          client_id                     = custom_oidc_v2.value.client_id
          name                          = custom_oidc_v2.value.name
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          authorisation_endpoint        = custom_oidc_v2.value.authorisation_endpoint
          certification_uri             = custom_oidc_v2.value.certification_uri
          client_credential_method      = custom_oidc_v2.value.client_credential_method
          client_secret_setting_name    = "${custom_oidc_v2.value.name}_PROVIDER_AUTHENTICATION_SECRET"
          issuer_endpoint               = custom_oidc_v2.value.issuer_endpoint
          name_claim_type               = custom_oidc_v2.value.name_claim_type
          scopes                        = custom_oidc_v2.value.scopes
          token_endpoint                = custom_oidc_v2.value.token_endpoint
        }
      }
      dynamic "facebook_v2" {
        for_each = auth_settings_v2.value.facebook_v2

        content {
          app_id                  = facebook_v2.value.app_id
          app_secret_setting_name = facebook_v2.value.app_secret_setting_name
          graph_api_version       = facebook_v2.value.graph_api_version
          login_scopes            = facebook_v2.value.login_scopes
        }
      }
      dynamic "github_v2" {
        for_each = auth_settings_v2.value.github_v2

        content {
          client_id                  = github_v2.value.client_id
          client_secret_setting_name = github_v2.value.client_secret_setting_name
          login_scopes               = github_v2.value.login_scopes
        }
      }
      dynamic "google_v2" {
        for_each = auth_settings_v2.value.google_v2

        content {
          client_id                  = google_v2.value.client_id
          client_secret_setting_name = google_v2.value.client_secret_setting_name
          allowed_audiences          = google_v2.value.allowed_audiences
          login_scopes               = google_v2.value.login_scopes
        }
      }
      dynamic "microsoft_v2" {
        for_each = auth_settings_v2.value.microsoft_v2

        content {
          client_id                  = microsoft_v2.value.client_id
          client_secret_setting_name = microsoft_v2.value.client_secret_setting_name
          allowed_audiences          = microsoft_v2.value.allowed_audiences
          login_scopes               = microsoft_v2.value.login_scopes
        }
      }
      dynamic "twitter_v2" {
        for_each = auth_settings_v2.value.twitter_v2

        content {
          consumer_key                 = twitter_v2.value.consumer_key
          consumer_secret_setting_name = twitter_v2.value.consumer_secret_setting_name
        }
      }
    }
  }
  dynamic "backup" {
    for_each = each.value.backup

    content {
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url
      enabled             = backup.value.enabled

      dynamic "schedule" {
        for_each = backup.value.schedule

        content {
          frequency_interval       = schedule.value.frequency_interval
          frequency_unit           = schedule.value.frequency_unit
          keep_at_least_one_backup = schedule.value.keep_at_least_one_backup
          retention_period_days    = schedule.value.retention_period_days
          start_time               = schedule.value.start_time
        }
      }
    }
  }
  dynamic "connection_string" {
    for_each = each.value.connection_strings

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
  dynamic "logs" {
    for_each = contains(local.webapp_slots_with_logs_keys, each.key) ? { for k, v in each.value.logs : k => v if(lower(v.application_logs[local.webapp_slot_lk[each.key].file_system_level_key].file_system_level)) != "off" && v.application_logs[local.webapp_slot_lk[each.key].file_system_level_key].file_system_level != null } : {}

    content {
      detailed_error_messages = logs.value.detailed_error_messages
      failed_request_tracing  = logs.value.failed_request_tracing

      dynamic "application_logs" {
        for_each = [for x in logs.value.application_logs : x if x.azure_blob_storage == null]

        content {
          file_system_level = application_logs.value.file_system_level
        }
      }
      dynamic "application_logs" {
        for_each = [for x in logs.value.application_logs : x if x.azure_blob_storage != null]

        content {
          file_system_level = application_logs.value.file_system_level

          azure_blob_storage {
            level             = application_logs.value.azure_blob_storage.level
            retention_in_days = application_logs.value.azure_blob_storage.retention_in_days
            sas_url           = application_logs.value.azure_blob_storage.sas_url
          }
        }
      }
      dynamic "http_logs" {
        for_each = [for x in logs.value.http_logs : x if x.azure_blob_storage_http != null]

        content {
          azure_blob_storage {
            sas_url           = http_logs.value.azure_blob_storage_http.sas_url
            retention_in_days = http_logs.value.azure_blob_storage_http.retention_in_days
          }
        }
      }
      dynamic "http_logs" {
        for_each = [for x in logs.value.http_logs : x if x.file_system != null]

        content {
          file_system {
            retention_in_days = http_logs.value.file_system.retention_in_days
            retention_in_mb   = http_logs.value.file_system.retention_in_mb
          }
        }
      }
    }
  }
  dynamic "storage_account" {
    for_each = each.value.storage_shares_to_mount

    content {
      access_key   = storage_account.value.access_key
      account_name = storage_account.value.account_name
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      mount_path   = storage_account.value.mount_path
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_linux_web_app_slot" "this" {
  for_each = { for slot, slot_values in var.deployment_slots : slot => slot_values if var.kind == "webapp" && var.os_type == "Linux" && var.deployment_slots != null }

  app_service_id                                 = azurerm_linux_web_app.this[0].id
  name                                           = coalesce(each.value.name, each.key)
  app_settings                                   = var.enable_application_insights ? merge({ "APPLICATIONINSIGHTS_CONNECTION_STRING" = (each.value.site_config.slot_application_insights_object_key != null ? coalesce(each.value.site_config.application_insights_connection_string, azurerm_application_insights.slot[each.value.site_config.slot_application_insights_object_key].connection_string, azurerm_application_insights.this[0].connection_string) : coalesce(each.value.site_config.application_insights_connection_string, azurerm_application_insights.this[0].connection_string)) }, { "APPINSIGHTS_INSTRUMENTATIONKEY" = (each.value.site_config.slot_application_insights_object_key != null ? coalesce(each.value.site_config.application_insights_key, azurerm_application_insights.slot[each.value.site_config.slot_application_insights_object_key].instrumentation_key, azurerm_application_insights.this[0].instrumentation_key) : coalesce(each.value.site_config.application_insights_key, azurerm_application_insights.this[0].instrumentation_key)) }, each.value.app_settings) : each.value.app_settings
  client_affinity_enabled                        = each.value.client_affinity_enabled
  client_certificate_enabled                     = each.value.client_certificate_enabled
  client_certificate_exclusion_paths             = each.value.client_certificate_exclusion_paths
  client_certificate_mode                        = each.value.client_certificate_mode
  enabled                                        = each.value.enabled
  ftp_publish_basic_authentication_enabled       = each.value.site_config.ftps_state == "Disabled" ? false : each.value.ftp_publish_basic_authentication_enabled
  https_only                                     = each.value.https_only
  key_vault_reference_identity_id                = each.value.key_vault_reference_identity_id
  public_network_access_enabled                  = each.value.public_network_access_enabled
  service_plan_id                                = each.value.service_plan_id
  tags                                           = each.value.tags
  virtual_network_subnet_id                      = each.value.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = each.value.site_config.ftps_state == "Disabled" ? false : each.value.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = each.value.zip_deploy_file

  site_config {
    always_on                                     = each.value.site_config.always_on
    api_definition_url                            = each.value.site_config.api_definition_url
    api_management_api_id                         = each.value.site_config.api_management_api_id
    app_command_line                              = each.value.site_config.app_command_line
    container_registry_managed_identity_client_id = each.value.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = each.value.site_config.container_registry_use_managed_identity
    default_documents                             = each.value.site_config.default_documents
    ftps_state                                    = each.value.site_config.ftps_state
    health_check_eviction_time_in_min             = each.value.site_config.health_check_eviction_time_in_min
    health_check_path                             = each.value.site_config.health_check_path
    http2_enabled                                 = each.value.site_config.http2_enabled
    ip_restriction_default_action                 = each.value.site_config.ip_restriction_default_action
    load_balancing_mode                           = each.value.site_config.load_balancing_mode
    managed_pipeline_mode                         = each.value.site_config.managed_pipeline_mode
    minimum_tls_version                           = each.value.site_config.minimum_tls_version
    remote_debugging_enabled                      = each.value.site_config.remote_debugging_enabled
    remote_debugging_version                      = each.value.site_config.remote_debugging_version
    scm_ip_restriction_default_action             = each.value.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = each.value.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = each.value.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                             = each.value.site_config.use_32_bit_worker
    vnet_route_all_enabled                        = each.value.site_config.vnet_route_all_enabled
    websockets_enabled                            = each.value.site_config.websockets_enabled
    worker_count                                  = each.value.site_config.worker_count

    dynamic "application_stack" {
      for_each = each.value.site_config.application_stack

      content {
        docker_image_name        = application_stack.value.docker_image_name
        docker_registry_password = application_stack.value.docker_registry_password
        docker_registry_url      = application_stack.value.docker_registry_url
        docker_registry_username = application_stack.value.docker_registry_username
        dotnet_version           = application_stack.value.dotnet_version != null ? application_stack.value.dotnet_version : null
        go_version               = application_stack.value.go_version != null ? application_stack.value.go_version : null
        java_server              = application_stack.value.java_server != null ? application_stack.value.java_server : null
        java_server_version      = application_stack.value.java_server_version != null ? application_stack.value.java_server_version : null
        java_version             = application_stack.value.java_version != null ? application_stack.value.java_version : null
        node_version             = application_stack.value.node_version != null ? application_stack.value.node_version : null
        php_version              = application_stack.value.php_version != null ? application_stack.value.php_version : null
        python_version           = application_stack.value.python_version
        ruby_version             = application_stack.value.ruby_version != null ? application_stack.value.ruby_version : null
      }
    }
    dynamic "auto_heal_setting" {
      for_each = each.value.auto_heal_setting

      content {
        action {
          action_type                    = auto_heal_setting.value.action.action_type
          minimum_process_execution_time = auto_heal_setting.value.action.minimum_process_execution_time
        }
        trigger {
          dynamic "requests" {
            for_each = auto_heal_setting.value.trigger.requests

            content {
              count    = requests.value.trigger.requests.count
              interval = requests.value.trigger.requests.interval
            }
          }
          dynamic "slow_request" {
            for_each = auto_heal_setting.value.trigger.slow_request

            content {
              count      = slow_request.value.count
              interval   = slow_request.value.interval
              time_taken = slow_request.value.time_taken
            }
          }
          dynamic "slow_request_with_path" {
            for_each = auto_heal_setting.value.trigger.slow_request_with_path

            content {
              count      = slow_request_with_path.value.count
              interval   = slow_request_with_path.value.interval
              time_taken = slow_request_with_path.value.time_taken
              path       = slow_request_with_path.value.path
            }
          }
          dynamic "status_code" {
            for_each = auto_heal_setting.value.trigger.status_code

            content {
              count             = status_code.value.count
              interval          = status_code.value.interval
              status_code_range = status_code.value.status_code_range
              path              = status_code.value.path
              sub_status        = status_code.value.sub_status
              win32_status_code = status_code.value.win32_status_code
            }
          }
        }
      }
    }
    dynamic "cors" {
      for_each = each.value.site_config.cors

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
    dynamic "ip_restriction" {
      for_each = each.value.site_config.ip_restriction

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
      for_each = each.value.site_config.scm_ip_restriction

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
  dynamic "auth_settings" {
    for_each = each.value.auth_settings

    content {
      enabled                        = auth_settings.value.enabled
      additional_login_parameters    = auth_settings.value.additional_login_parameters
      allowed_external_redirect_urls = auth_settings.value.allowed_external_redirect_urls
      default_provider               = auth_settings.value.default_provider
      issuer                         = auth_settings.value.issuer
      runtime_version                = auth_settings.value.runtime_version
      token_refresh_extension_hours  = auth_settings.value.token_refresh_extension_hours
      token_store_enabled            = auth_settings.value.token_store_enabled
      unauthenticated_client_action  = auth_settings.value.unauthenticated_client_action

      dynamic "active_directory" {
        for_each = auth_settings.value.active_directory

        content {
          client_id                  = active_directory.value.client_id
          allowed_audiences          = active_directory.value.allowed_audiences
          client_secret              = active_directory.value.client_secret
          client_secret_setting_name = active_directory.value.client_secret_setting_name
        }
      }
      dynamic "facebook" {
        for_each = auth_settings.value.facebook

        content {
          app_id                  = facebook.value.app_id
          app_secret              = facebook.value.app_secret
          app_secret_setting_name = facebook.value.app_secret_setting_name
          oauth_scopes            = facebook.value.oauth_scopes
        }
      }
      dynamic "github" {
        for_each = auth_settings.value.github

        content {
          client_id                  = github.value.client_id
          client_secret              = github.value.client_secret
          client_secret_setting_name = github.value.client_secret_setting_name
          oauth_scopes               = github.value.oauth_scopes
        }
      }
      dynamic "google" {
        for_each = auth_settings.value.google

        content {
          client_id                  = google.value.client_id
          client_secret              = google.value.client_secret
          client_secret_setting_name = google.value.client_secret_setting_name
          oauth_scopes               = google.value.oauth_scopes
        }
      }
      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft

        content {
          client_id                  = microsoft.value.client_id
          client_secret              = microsoft.value.client_secret
          client_secret_setting_name = microsoft.value.client_secret_setting_name
          oauth_scopes               = microsoft.value.oauth_scopes
        }
      }
      dynamic "twitter" {
        for_each = auth_settings.value.twitter

        content {
          consumer_key                 = twitter.value.consumer_key
          consumer_secret              = twitter.value.consumer_secret
          consumer_secret_setting_name = twitter.value.consumer_secret_setting_name
        }
      }
    }
  }
  dynamic "auth_settings_v2" {
    for_each = each.value.auth_settings_v2

    content {
      auth_enabled                            = auth_settings_v2.value.auth_enabled
      config_file_path                        = auth_settings_v2.value.config_file_path
      default_provider                        = auth_settings_v2.value.default_provider
      excluded_paths                          = auth_settings_v2.value.excluded_paths
      forward_proxy_convention                = auth_settings_v2.value.forward_proxy_convention
      forward_proxy_custom_host_header_name   = auth_settings_v2.value.forward_proxy_custom_host_header_name
      forward_proxy_custom_scheme_header_name = auth_settings_v2.value.forward_proxy_custom_scheme_header_name
      http_route_api_prefix                   = auth_settings_v2.value.http_route_api_prefix
      require_authentication                  = auth_settings_v2.value.require_authentication
      require_https                           = auth_settings_v2.value.require_https
      runtime_version                         = auth_settings_v2.value.runtime_version
      unauthenticated_action                  = auth_settings_v2.value.unauthenticated_action

      dynamic "login" {
        for_each = auth_settings_v2.value.login

        content {
          allowed_external_redirect_urls    = login.value.allowed_external_redirect_urls
          cookie_expiration_convention      = login.value.cookie_expiration_convention
          cookie_expiration_time            = login.value.cookie_expiration_time
          logout_endpoint                   = login.value.logout_endpoint
          nonce_expiration_time             = login.value.nonce_expiration_time
          preserve_url_fragments_for_logins = login.value.preserve_url_fragments_for_logins
          token_refresh_extension_time      = login.value.token_refresh_extension_time
          token_store_enabled               = login.value.token_store_enabled
          token_store_path                  = login.value.token_store_path
          token_store_sas_setting_name      = login.value.token_store_sas_setting_name
          validate_nonce                    = login.value.validate_nonce
        }
      }
      dynamic "active_directory_v2" {
        for_each = auth_settings_v2.value.active_directory_v2

        content {
          client_id                            = active_directory_v2.value.client_id
          tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
          allowed_applications                 = active_directory_v2.value.allowed_applications
          allowed_audiences                    = active_directory_v2.value.allowed_audiences
          allowed_groups                       = active_directory_v2.value.allowed_groups
          allowed_identities                   = active_directory_v2.value.allowed_identities
          client_secret_certificate_thumbprint = active_directory_v2.value.client_secret_certificate_thumbprint
          client_secret_setting_name           = active_directory_v2.value.client_secret_setting_name
          jwt_allowed_client_applications      = active_directory_v2.value.jwt_allowed_client_applications
          jwt_allowed_groups                   = active_directory_v2.value.jwt_allowed_groups
          login_parameters                     = active_directory_v2.value.login_parameters
          www_authentication_disabled          = active_directory_v2.value.www_authentication_disabled
        }
      }
      dynamic "apple_v2" {
        for_each = auth_settings_v2.value.apple_v2

        content {
          client_id                  = apple_v2.value.client_id
          client_secret_setting_name = apple_v2.value.client_secret_setting_name
          login_scopes               = apple_v2.value.login_scopes
        }
      }
      dynamic "azure_static_web_app_v2" {
        for_each = auth_settings_v2.value.azure_static_web_app_v2

        content {
          client_id = azure_static_web_app_v2.value.client_id
        }
      }
      dynamic "custom_oidc_v2" {
        for_each = auth_settings_v2.value.custom_oidc_v2

        content {
          client_id                     = custom_oidc_v2.value.client_id
          name                          = custom_oidc_v2.value.name
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          authorisation_endpoint        = custom_oidc_v2.value.authorisation_endpoint
          certification_uri             = custom_oidc_v2.value.certification_uri
          client_credential_method      = custom_oidc_v2.value.client_credential_method
          client_secret_setting_name    = "${custom_oidc_v2.value.name}_PROVIDER_AUTHENTICATION_SECRET"
          issuer_endpoint               = custom_oidc_v2.value.issuer_endpoint
          name_claim_type               = custom_oidc_v2.value.name_claim_type
          scopes                        = custom_oidc_v2.value.scopes
          token_endpoint                = custom_oidc_v2.value.token_endpoint
        }
      }
      dynamic "facebook_v2" {
        for_each = auth_settings_v2.value.facebook_v2

        content {
          app_id                  = facebook_v2.value.app_id
          app_secret_setting_name = facebook_v2.value.app_secret_setting_name
          graph_api_version       = facebook_v2.value.graph_api_version
          login_scopes            = facebook_v2.value.login_scopes
        }
      }
      dynamic "github_v2" {
        for_each = auth_settings_v2.value.github_v2

        content {
          client_id                  = github_v2.value.client_id
          client_secret_setting_name = github_v2.value.client_secret_setting_name
          login_scopes               = github_v2.value.login_scopes
        }
      }
      dynamic "google_v2" {
        for_each = auth_settings_v2.value.google_v2

        content {
          client_id                  = google_v2.value.client_id
          client_secret_setting_name = google_v2.value.client_secret_setting_name
          allowed_audiences          = google_v2.value.allowed_audiences
          login_scopes               = google_v2.value.login_scopes
        }
      }
      dynamic "microsoft_v2" {
        for_each = auth_settings_v2.value.microsoft_v2

        content {
          client_id                  = microsoft_v2.value.client_id
          client_secret_setting_name = microsoft_v2.value.client_secret_setting_name
          allowed_audiences          = microsoft_v2.value.allowed_audiences
          login_scopes               = microsoft_v2.value.login_scopes
        }
      }
      dynamic "twitter_v2" {
        for_each = auth_settings_v2.value.twitter_v2

        content {
          consumer_key                 = twitter_v2.value.consumer_key
          consumer_secret_setting_name = twitter_v2.value.consumer_secret_setting_name
        }
      }
    }
  }
  dynamic "backup" {
    for_each = each.value.backup

    content {
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url
      enabled             = backup.value.enabled

      dynamic "schedule" {
        for_each = backup.value.schedule

        content {
          frequency_interval       = schedule.value.frequency_interval
          frequency_unit           = schedule.value.frequency_unit
          keep_at_least_one_backup = schedule.value.keep_at_least_one_backup
          retention_period_days    = schedule.value.retention_period_days
          start_time               = schedule.value.start_time
        }
      }
    }
  }
  dynamic "connection_string" {
    for_each = each.value.connection_strings

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
  dynamic "logs" {
    for_each = contains(local.webapp_slots_with_logs_keys, each.key) ? { for k, v in each.value.logs : k => v if(lower(v.application_logs[local.webapp_slot_lk[each.key].file_system_level_key].file_system_level)) != "off" && v.application_logs[local.webapp_slot_lk[each.key].file_system_level_key].file_system_level != null } : {}

    content {
      detailed_error_messages = logs.value.detailed_error_messages
      failed_request_tracing  = logs.value.failed_request_tracing

      dynamic "application_logs" {
        for_each = [for x in logs.value.application_logs : x if x.azure_blob_storage == null]

        content {
          file_system_level = application_logs.value.file_system_level
        }
      }
      dynamic "application_logs" {
        for_each = [for x in logs.value.application_logs : x if x.azure_blob_storage != null]

        content {
          file_system_level = application_logs.value.file_system_level

          azure_blob_storage {
            level             = application_logs.value.azure_blob_storage.level
            retention_in_days = application_logs.value.azure_blob_storage.retention_in_days
            sas_url           = application_logs.value.azure_blob_storage.sas_url
          }
        }
      }
      dynamic "http_logs" {
        for_each = [for x in logs.value.http_logs : x if x.azure_blob_storage_http != null]

        content {
          azure_blob_storage {
            sas_url           = http_logs.value.azure_blob_storage_http.sas_url
            retention_in_days = http_logs.value.azure_blob_storage_http.retention_in_days
          }
        }
      }
      dynamic "http_logs" {
        for_each = [for x in logs.value.http_logs : x if x.file_system != null]

        content {
          file_system {
            retention_in_days = http_logs.value.file_system.retention_in_days
            retention_in_mb   = http_logs.value.file_system.retention_in_mb
          }
        }
      }
    }
  }
  dynamic "storage_account" {
    for_each = each.value.storage_shares_to_mount

    content {
      access_key   = storage_account.value.access_key
      account_name = storage_account.value.account_name
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      mount_path   = storage_account.value.mount_path
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_web_app_active_slot" "this" {
  count = var.kind == "webapp" && var.app_service_active_slot != null ? 1 : 0

  slot_id                  = var.os_type == "Windows" ? azurerm_windows_web_app_slot.this[var.app_service_active_slot.slot_key].id : azurerm_linux_web_app_slot.this[var.app_service_active_slot.slot_key].id
  overwrite_network_config = var.app_service_active_slot.overwrite_network_config
}
