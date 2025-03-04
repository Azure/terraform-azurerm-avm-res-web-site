resource "azurerm_windows_function_app" "this" {
  count = var.kind == "functionapp" && var.os_type == "Windows" && var.function_app_uses_fc1 == false ? 1 : 0

  location                                       = var.location
  name                                           = var.name
  resource_group_name                            = var.resource_group_name
  service_plan_id                                = var.service_plan_resource_id
  app_settings                                   = var.app_settings
  builtin_logging_enabled                        = var.builtin_logging_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  client_certificate_mode                        = var.client_certificate_mode
  content_share_force_disabled                   = var.content_share_force_disabled
  daily_memory_time_quota                        = var.daily_memory_time_quota
  enabled                                        = var.enabled
  ftp_publish_basic_authentication_enabled       = var.site_config.ftps_state == "Disabled" ? false : var.ftp_publish_basic_authentication_enabled
  functions_extension_version                    = var.functions_extension_version
  https_only                                     = var.https_only
  key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  public_network_access_enabled                  = var.public_network_access_enabled
  storage_account_access_key                     = var.storage_account_access_key != null && var.storage_uses_managed_identity != true ? var.storage_account_access_key : null
  storage_account_name                           = var.storage_account_name
  storage_key_vault_secret_id                    = var.storage_key_vault_secret_id
  storage_uses_managed_identity                  = var.storage_uses_managed_identity == true && var.storage_account_access_key == null ? var.storage_uses_managed_identity : null
  tags                                           = var.tags
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = var.site_config.ftps_state == "Disabled" ? false : var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = var.zip_deploy_file

  site_config {
    always_on                              = var.site_config.always_on
    api_definition_url                     = var.site_config.api_definition_url
    api_management_api_id                  = var.site_config.api_management_api_id
    app_command_line                       = var.site_config.app_command_line
    app_scale_limit                        = var.site_config.app_scale_limit
    application_insights_connection_string = var.enable_application_insights ? coalesce(azurerm_application_insights.this[0].connection_string, var.site_config.application_insights_connection_string) : var.site_config.application_insights_connection_string
    application_insights_key               = var.enable_application_insights ? coalesce(azurerm_application_insights.this[0].instrumentation_key, var.site_config.application_insights_key) : var.site_config.application_insights_key
    default_documents                      = var.site_config.default_documents
    elastic_instance_minimum               = var.site_config.elastic_instance_minimum
    ftps_state                             = var.site_config.ftps_state
    health_check_eviction_time_in_min      = var.site_config.health_check_eviction_time_in_min
    health_check_path                      = var.site_config.health_check_path
    http2_enabled                          = var.site_config.http2_enabled
    ip_restriction_default_action          = var.site_config.ip_restriction_default_action
    load_balancing_mode                    = var.site_config.load_balancing_mode
    managed_pipeline_mode                  = var.site_config.managed_pipeline_mode
    minimum_tls_version                    = var.site_config.minimum_tls_version
    pre_warmed_instance_count              = var.site_config.pre_warmed_instance_count
    remote_debugging_enabled               = var.site_config.remote_debugging_enabled
    remote_debugging_version               = var.site_config.remote_debugging_version
    runtime_scale_monitoring_enabled       = var.site_config.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action      = var.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version                = var.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction            = var.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                      = var.site_config.use_32_bit_worker
    vnet_route_all_enabled                 = var.site_config.vnet_route_all_enabled
    websockets_enabled                     = var.site_config.websockets_enabled
    worker_count                           = var.site_config.worker_count

    dynamic "app_service_logs" {
      for_each = var.site_config.app_service_logs

      content {
        disk_quota_mb         = app_service_logs.value.disk_quota_mb
        retention_period_days = app_service_logs.value.retention_period_days
      }
    }
    dynamic "application_stack" {
      for_each = var.site_config.application_stack

      content {
        dotnet_version              = application_stack.value.dotnet_version != null ? application_stack.value.dotnet_version : null
        java_version                = application_stack.value.java_version != null ? application_stack.value.java_version : null
        node_version                = application_stack.value.node_version != null ? application_stack.value.node_version : null
        powershell_core_version     = application_stack.value.powershell_core_version != null ? application_stack.value.powershell_core_version : null
        use_custom_runtime          = application_stack.value.use_custom_runtime == true ? application_stack.value.use_custom_runtime : null
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime != null ? application_stack.value.use_dotnet_isolated_runtime : null
      }
    }
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
  dynamic "auth_settings" {
    for_each = var.auth_settings

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
    for_each = var.auth_settings_v2

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
    for_each = var.backup

    content {
      name                = coalesce(backup.value.name, "${var.name}-backup")
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
  dynamic "sticky_settings" {
    for_each = var.sticky_settings

    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }
  dynamic "storage_account" {
    for_each = var.storage_shares_to_mount

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
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_linux_function_app" "this" {
  count = var.kind == "functionapp" && var.os_type == "Linux" && var.function_app_uses_fc1 == false ? 1 : 0

  location                                       = var.location
  name                                           = var.name
  resource_group_name                            = var.resource_group_name
  service_plan_id                                = var.service_plan_resource_id
  app_settings                                   = var.app_settings
  builtin_logging_enabled                        = var.builtin_logging_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  client_certificate_mode                        = var.client_certificate_mode
  content_share_force_disabled                   = var.content_share_force_disabled
  daily_memory_time_quota                        = var.daily_memory_time_quota
  enabled                                        = var.enabled
  ftp_publish_basic_authentication_enabled       = var.site_config.ftps_state == "Disabled" ? false : var.ftp_publish_basic_authentication_enabled
  functions_extension_version                    = var.functions_extension_version
  https_only                                     = var.https_only
  key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  public_network_access_enabled                  = var.public_network_access_enabled
  storage_account_access_key                     = var.storage_account_access_key != null && var.storage_uses_managed_identity != true ? var.storage_account_access_key : null
  storage_account_name                           = var.storage_account_name
  storage_key_vault_secret_id                    = var.storage_key_vault_secret_id
  storage_uses_managed_identity                  = var.storage_uses_managed_identity == true && var.storage_account_access_key == null ? var.storage_uses_managed_identity : null
  tags                                           = var.tags
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = var.site_config.ftps_state == "Disabled" ? false : var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = var.zip_deploy_file

  site_config {
    always_on                                     = var.site_config.always_on
    api_definition_url                            = var.site_config.api_definition_url
    api_management_api_id                         = var.site_config.api_management_api_id
    app_command_line                              = var.site_config.app_command_line
    app_scale_limit                               = var.site_config.app_scale_limit
    application_insights_connection_string        = var.enable_application_insights ? coalesce(azurerm_application_insights.this[0].connection_string, var.site_config.application_insights_connection_string) : var.site_config.application_insights_connection_string
    application_insights_key                      = var.enable_application_insights ? coalesce(azurerm_application_insights.this[0].instrumentation_key, var.site_config.application_insights_key) : var.site_config.application_insights_key
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    default_documents                             = var.site_config.default_documents
    elastic_instance_minimum                      = var.site_config.elastic_instance_minimum
    ftps_state                                    = var.site_config.ftps_state
    health_check_eviction_time_in_min             = var.site_config.health_check_eviction_time_in_min
    health_check_path                             = var.site_config.health_check_path
    http2_enabled                                 = var.site_config.http2_enabled
    ip_restriction_default_action                 = var.site_config.ip_restriction_default_action
    load_balancing_mode                           = var.site_config.load_balancing_mode
    managed_pipeline_mode                         = var.site_config.managed_pipeline_mode
    minimum_tls_version                           = var.site_config.minimum_tls_version
    pre_warmed_instance_count                     = var.site_config.pre_warmed_instance_count
    remote_debugging_enabled                      = var.site_config.remote_debugging_enabled
    remote_debugging_version                      = var.site_config.remote_debugging_version
    runtime_scale_monitoring_enabled              = var.site_config.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action             = var.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = var.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = var.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                             = var.site_config.use_32_bit_worker
    vnet_route_all_enabled                        = var.site_config.vnet_route_all_enabled
    websockets_enabled                            = var.site_config.websockets_enabled
    worker_count                                  = var.site_config.worker_count

    dynamic "app_service_logs" {
      for_each = var.site_config.app_service_logs

      content {
        disk_quota_mb         = app_service_logs.value.disk_quota_mb
        retention_period_days = app_service_logs.value.retention_period_days
      }
    }
    dynamic "application_stack" {
      for_each = var.site_config.application_stack

      content {
        dotnet_version              = application_stack.value.dotnet_version != null ? application_stack.value.dotnet_version : null
        java_version                = application_stack.value.java_version != null ? application_stack.value.java_version : null
        node_version                = application_stack.value.node_version != null ? application_stack.value.node_version : null
        powershell_core_version     = application_stack.value.powershell_core_version != null ? application_stack.value.powershell_core_version : null
        python_version              = application_stack.value.python_version != null ? application_stack.value.python_version : null
        use_custom_runtime          = application_stack.value.use_custom_runtime == true ? application_stack.value.use_custom_runtime : null
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime != null ? application_stack.value.use_dotnet_isolated_runtime : null

        dynamic "docker" {
          for_each = application_stack.value.docker == null ? [] : application_stack.value.docker

          content {
            image_name        = docker.value.image_name
            image_tag         = docker.value.image_tag
            registry_url      = docker.value.registry_url
            registry_password = docker.value.registry_password
            registry_username = docker.value.registry_username
          }
        }
      }
    }
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
  dynamic "auth_settings" {
    for_each = var.auth_settings

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
    for_each = var.auth_settings_v2

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
    for_each = var.backup

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
  dynamic "sticky_settings" {
    for_each = var.sticky_settings

    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }
  dynamic "storage_account" {
    for_each = var.storage_shares_to_mount

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
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_function_app_flex_consumption" "this" {
  count = var.kind == "functionapp" && var.os_type == "Linux" && var.function_app_uses_fc1 == true ? 1 : 0

  location                           = var.location
  name                               = var.name
  resource_group_name                = var.resource_group_name
  service_plan_id                    = var.service_plan_resource_id
  app_settings                       = var.app_settings
  client_certificate_enabled         = var.client_certificate_enabled
  client_certificate_exclusion_paths = var.client_certificate_exclusion_paths
  client_certificate_mode            = var.client_certificate_mode
  # content_share_force_disabled                   = var.content_share_force_disabled
  # daily_memory_time_quota                        = var.daily_memory_time_quota
  enabled = var.enabled
  # https_only                                     = var.https_only
  # key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  public_network_access_enabled                  = var.public_network_access_enabled
  tags                                           = var.tags
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = var.site_config.ftps_state == "Disabled" ? false : var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = var.zip_deploy_file

  runtime_name           = var.runtime_name
  runtime_version        = var.runtime_version
  maximum_instance_count = var.maximum_instance_count
  instance_memory_in_mb  = var.instance_memory_in_mb

  storage_access_key          = var.storage_account_access_key
  storage_container_endpoint  = var.storage_container_endpoint
  storage_authentication_type = var.storage_authentication_type
  storage_container_type      = var.storage_container_type

  site_config {
    api_definition_url                            = var.site_config.api_definition_url
    api_management_api_id                         = var.site_config.api_management_api_id
    app_command_line                              = var.site_config.app_command_line
    application_insights_connection_string        = var.enable_application_insights ? coalesce(azurerm_application_insights.this[0].connection_string, var.site_config.application_insights_connection_string) : var.site_config.application_insights_connection_string
    application_insights_key                      = var.enable_application_insights ? coalesce(azurerm_application_insights.this[0].instrumentation_key, var.site_config.application_insights_key) : var.site_config.application_insights_key
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    default_documents                             = var.site_config.default_documents
    elastic_instance_minimum                      = var.site_config.elastic_instance_minimum
    health_check_eviction_time_in_min             = var.site_config.health_check_eviction_time_in_min
    health_check_path                             = var.site_config.health_check_path
    http2_enabled                                 = var.site_config.http2_enabled
    ip_restriction_default_action                 = var.site_config.ip_restriction_default_action
    load_balancing_mode                           = var.site_config.load_balancing_mode
    managed_pipeline_mode                         = var.site_config.managed_pipeline_mode
    minimum_tls_version                           = var.site_config.minimum_tls_version
    remote_debugging_enabled                      = var.site_config.remote_debugging_enabled
    remote_debugging_version                      = var.site_config.remote_debugging_version
    runtime_scale_monitoring_enabled              = var.site_config.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action             = var.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = var.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = var.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                             = var.site_config.use_32_bit_worker
    websockets_enabled                            = var.site_config.websockets_enabled
    worker_count                                  = var.site_config.worker_count

    dynamic "app_service_logs" {
      for_each = var.site_config.app_service_logs

      content {
        disk_quota_mb         = app_service_logs.value.disk_quota_mb
        retention_period_days = app_service_logs.value.retention_period_days
      }
    }

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
  dynamic "auth_settings" {
    for_each = var.auth_settings

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
    for_each = var.auth_settings_v2

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
  # dynamic "backup" {
  #   for_each = var.backup

  #   content {
  #     name                = backup.value.name
  #     storage_account_url = backup.value.storage_account_url
  #     enabled             = backup.value.enabled

  #     dynamic "schedule" {
  #       for_each = backup.value.schedule

  #       content {
  #         frequency_interval       = schedule.value.frequency_interval
  #         frequency_unit           = schedule.value.frequency_unit
  #         keep_at_least_one_backup = schedule.value.keep_at_least_one_backup
  #         retention_period_days    = schedule.value.retention_period_days
  #         start_time               = schedule.value.start_time
  #       }
  #     }
  #   }
  # }
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
  dynamic "sticky_settings" {
    for_each = var.sticky_settings

    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
