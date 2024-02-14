resource "azurerm_windows_function_app" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = var.name 
  resource_group_name = var.resource_group_name
  location            = coalesce(var.location)
  service_plan_id            = var.service_plan_resource_id

  app_settings = var.app_settings

  dynamic "auth_settings" {
    for_each = var.auth_settings

    content {
      enabled = auth_settings.value.enabled

      dynamic "active_directory" {
        for_each = auth_settings.value.active_directory

        content {
          client_id = active_directory.value.client_id
          allowed_audiences = active_directory.value.allowed_audiences
          client_secret = active_directory.value.client_secret
          client_secret_setting_name = active_directory.value.client_secret_setting_name
        }
      }

      additional_login_parameters = auth_settings.value.additional_login_parameters
      allowed_external_redirect_urls = auth_settings.value.allowed_external_redirect_urls
      default_provider = auth_settings.value.default_provider

      dynamic "facebook" {
        for_each = auth_settings.value.facebook
        
        content {
          app_id = facebook.value.app_id
          app_secret = facebook.value.app_secret
          app_secret_setting_name = facebook.value.app_secret_setting_name
          oauth_scopes = facebook.value.oauth_scopes
        }
      }

      dynamic "github" {
        for_each = auth_settings.value.github

        content {
          client_id = github.value.client_id
          client_secret = github.value.client_secret
          client_secret_setting_name = github.value.client_secret_setting_name
          oauth_scopes = github.value.oauth_scopes
        } 
      }

      dynamic "google" {
        for_each = auth_settings.value.google

        content {
          client_id = google.value.client_id
          client_secret = google.value.client_secret
          client_secret_setting_name = google.value.client_secret_setting_name
          oauth_scopes = google.value.oauth_scopes
        }
      }

      issuer = auth_settings.value.issuer

      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft

        content {
          client_id = microsoft.value.client_id
          client_secret = microsoft.value.client_secret
          client_secret_setting_name = microsoft.value.client_secret_setting_name
          oauth_scopes = microsoft.value.oauth_scopes
        }
      }
      runtime_version = auth_settings.value.runtime_version
      token_refresh_extension_hours = auth_settings.value.token_refresh_extension_hours
      token_store_enabled = auth_settings.value.token_store_enabled

      dynamic "twitter" {
        for_each = auth_settings.value.twitter

        content {
          consumer_key = twitter.value.consumer_key
          consumer_secret = twitter.value.consumer_secret
          consumer_secret_setting_name = twitter.value.consumer_secret_setting_name
        }
      }
      unauthenticated_client_action = auth_settings.value.unauthenticated_client_action
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2

    content {
      auth_enabled = auth_settings_v2.value.auth_enabled
      runtime_version = auth_settings_v2.value.runtime_version
      config_file_path = auth_settings_v2.value.config_file_path
      require_authentication = auth_settings_v2.value.require_authentication
      unauthenticated_action = auth_settings_v2.value.unauthenticated_action
      default_provider = auth_settings_v2.value.default_provider
      excluded_paths = auth_settings_v2.value.excluded_paths
      require_https = auth_settings_v2.value.require_https
      http_route_api_prefix = auth_settings_v2.value.http_route_api_prefix
      forward_proxy_convention = auth_settings_v2.value.forward_proxy_convention
      forward_proxy_custom_host_header_name = auth_settings_v2.value.forward_proxy_custom_host_header_name
      forward_proxy_custom_scheme_header_name = auth_settings_v2.value.forward_proxy_custom_scheme_header_name
      
      dynamic "apple_v2" {
        for_each = auth_settings_v2.value.apple_v2

        content {
          client_id = apple_v2.value.client_id
          client_secret_setting_name = apple_v2.value.client_secret_setting_name
          login_scopes = apple_v2.value.login_scopes
        }
      }

      dynamic "active_directory_v2" {
        for_each = auth_settings_v2.value.active_directory_v2

        content {
          client_id = active_directory_v2.value.client_id
          tenant_auth_endpoint = active_directory_v2.value.tenant_auth_endpoint
          client_secret_setting_name = active_directory_v2.value.client_secret_setting_name
          client_secret_certificate_thumbprint = active_directory_v2.value.client_secret_certificate_thumbprint
          jwt_allowed_groups = active_directory_v2.value.jwt_allowed_groups
          jwt_allowed_client_applications = active_directory_v2.value.jwt_allowed_client_applications
          www_authentication_disabled = active_directory_v2.value.www_authentication_disabled
          allowed_groups = active_directory_v2.value.allowed_groups
          allowed_identities = active_directory_v2.value.allowed_identities
          allowed_applications = active_directory_v2.value.allowed_applications
          login_parameters = active_directory_v2.value.login_parameters
          allowed_audiences = active_directory_v2.value.allowed_audiences
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
          name = custom_oidc_v2.value.name
          client_id = custom_oidc_v2.value.client_id
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          name_claim_type = custom_oidc_v2.value.name_claim_type
          scopes = custom_oidc_v2.value.scopes
          client_credential_method = custom_oidc_v2.value.client_credential_method
          client_secret_setting_name = "${custom_oidc_v2.value.name}_PROVIDER_AUTHENTICATION_SECRET"
          authorisation_endpoint = custom_oidc_v2.value.authorisation_endpoint
          token_endpoint = custom_oidc_v2.value.token_endpoint
          issuer_endpoint = custom_oidc_v2.value.issuer_endpoint
          certification_uri = custom_oidc_v2.value.certification_uri
        }
        
      }
      dynamic "facebook_v2" {
        for_each = auth_settings_v2.value.facebook_v2
        content {
          app_id = facebook_v2.value.app_id
        app_secret_setting_name = facebook_v2.value.app_secret_setting_name
        graph_api_version = facebook_v2.value.graph_api_version
        login_scopes = facebook_v2.value.login_scopes
        }

      }
      dynamic "github_v2" {
        for_each = auth_settings_v2.value.github_v2

        content {
          client_id = github_v2.value.client_id
        client_secret_setting_name = github_v2.value.client_secret_setting_name
        login_scopes = github_v2.value.login_scopes
        }
      }
      dynamic "google_v2" {
        for_each = auth_settings_v2.value.google_v2
        content {
          client_id = google_v2.value.client_id
        client_secret_setting_name = google_v2.value.client_secret_setting_name
        allowed_audiences = google_v2.value.allowed_audiences
        login_scopes = google_v2.value.login_scopes
        }
        
      }
      dynamic "microsoft_v2" {
        for_each = auth_settings_v2.value.microsoft_v2
        content {
          client_id = microsoft_v2.value.client_id
        client_secret_setting_name = microsoft_v2.value.client_secret_setting_name
        allowed_audiences = microsoft_v2.value.allowed_audiences
        login_scopes = microsoft_v2.value.login_scopes
        }
      }
      dynamic "twitter_v2" {
        for_each = auth_settings_v2.value.twitter_v2
        content {
          consumer_key = twitter_v2.value.consumer_key
        consumer_secret_setting_name = twitter_v2.value.consumer_secret_setting_name
        }
      }
      dynamic "login" {
        for_each = auth_settings_v2.value.login

        content {
          logout_endpoint = login.value.logout_endpoint
          token_store_enabled = login.value.token_store_enabled
          token_refresh_extension_time = login.value.token_refresh_extension_time
          token_store_path = login.value.token_store_path
          token_store_sas_setting_name = login.value.token_store_sas_setting_name
          preserve_url_fragments_for_logins = login.value.preserve_url_fragments_for_logins
          allowed_external_redirect_urls = login.value.allowed_external_redirect_urls
          cookie_expiration_convention = login.value.cookie_expiration_convention
          cookie_expiration_time = login.value.cookie_expiration_time
          validate_nonce = login.value.validate_nonce
          nonce_expiration_time = login.value.nonce_expiration_time
        }
      }
    }
    
  }

  dynamic "backup" {
    for_each = var.backup

    content {
      name = backup.value.name

      dynamic "schedule" {
        for_each = backup.value.schedule

        content {
          frequency_interval = schedule.value.frequency_interval
          frequency_unit = schedule.value.frequency_unit
          keep_at_least_one_backup = schedule.value.keep_at_least_one_backup
          retention_period_days = schedule.value.retention_period_days
          start_time = schedule.value.start_time
        }
      }
      storage_account_url = backup.value.storage_account_url
      enabled = backup.value.enabled
    }
  }

  builtin_logging_enabled = var.builtin_logging_enabled
  client_certificate_enabled = var.client_certificate_enabled
  client_certificate_mode = var.client_certificate_mode
  client_certificate_exclusion_paths = var.client_certificate_exclusion_paths

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name = connection_string.value.name
      type = connection_string.value.type
      value = connection_string.value.value
    }
  }

  content_share_force_disabled = var.content_share_force_disabled
  daily_memory_time_quota = var.daily_memory_time_quota
  enabled = var.enabled
  ftp_publish_basic_authentication_enabled = var.ftp_publish_basic_authentication_enabled
  functions_extension_version = var.functions_extension_version
  https_only = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  
  dynamic "identity" {
    for_each = var.identities 

    content {
      type = identity.value.type
      identity_ids = identity.value.identity_ids
    }
    
  }

  key_vault_reference_identity_id = var.key_vault_reference_identity_id

  site_config {
    always_on = var.site_config.always_on
    api_definition_url = var.site_config.api_definition_url
    api_management_api_id = var.site_config.api_management_api_id
    app_command_line = var.site_config.app_command_line
    app_scale_limit = var.site_config.app_scale_limit
    application_insights_connection_string = var.site_config.application_insights_connection_string
    application_insights_key = var.site_config.application_insights_key

    dynamic "application_stack" {
      for_each = var.site_config.application_stack

      content {
        dotnet_version = application_stack.value.dotnet_version != null ? application_stack.value.dotnet_version : null
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime != null ? application_stack.value.use_dotnet_isolated_runtime : null
        java_version = application_stack.value.java_version != null ? application_stack.value.java_version : null
        node_version = application_stack.value.node_version != null ? application_stack.value.node_version : null
        powershell_core_version = application_stack.value.powershell_core_version != null ? application_stack.value.powershell_core_version : null
        use_custom_runtime = application_stack.value.use_custom_runtime == true ? application_stack.value.use_custom_runtime : null
      }
    }

    dynamic "app_service_logs" {
      for_each = var.site_config.app_service_logs

      content {
        disk_quota_mb = app_service_logs.value.disk_quota_mb
        retention_period_days = app_service_logs.value.retention_period_days
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors

      content {
        allowed_origins = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    default_documents = var.site_config.default_documents 
    elastic_instance_minimum = var.site_config.elastic_instance_minimum 
    ftps_state = var.site_config.ftps_state 
    health_check_path = var.site_config.health_check_path 
    health_check_eviction_time_in_min = var.site_config.health_check_eviction_time_in_min
    http2_enabled = var.site_config.http2_enabled

    dynamic "ip_restriction" {
      for_each = var.site_config.ip_restriction

      content {
        action = ip_restriction.value.action
          
        dynamic "headers" {
          for_each = ip_restriction.value.headers

          content {
            x_azure_fdid = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for = headers.value.x_forwarded_for
            x_forwarded_host = headers.value.x_forwarded_host
          }
        }

        ip_address = scm_ip_restriction.value.ip_address
        name = scm_ip_restriction.value.name
        priority = scm_ip_restriction.value.priority
        service_tag = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id

      }
    } 

      load_balancing_mode = var.site_config.load_balancing_mode 
      managed_pipeline_mode = var.site_config.managed_pipeline_mode 
      minimum_tls_version = var.site_config.minimum_tls_version
      pre_warmed_instance_count = var.site_config.pre_warmed_instance_count 
      remote_debugging_enabled = var.site_config.remote_debugging_enabled 
      remote_debugging_version = var.site_config.remote_debugging_version 
      runtime_scale_monitoring_enabled = var.site_config.runtime_scale_monitoring_enabled
      
      dynamic "scm_ip_restriction" { # one or more scm_ip_restriction blocks 
        for_each = var.site_config.scm_ip_restriction

        content {
          action = scm_ip_restriction.value.action
          
          dynamic "headers" {
            for_each = scm_ip_restriction.value.headers

            content {
              x_azure_fdid = headers.value.x_azure_fdid
              x_fd_health_probe = headers.value.x_fd_health_probe
              x_forwarded_for = headers.value.x_forwarded_for
              x_forwarded_host = headers.value.x_forwarded_host
            }
          }

          ip_address = scm_ip_restriction.value.ip_address
          name = scm_ip_restriction.value.name
          priority = scm_ip_restriction.value.priority
          service_tag = scm_ip_restriction.value.service_tag
          virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        }
      }

      scm_minimum_tls_version = var.site_config.scm_minimum_tls_version
      scm_use_main_ip_restriction = var.site_config.scm_use_main_ip_restriction
      use_32_bit_worker = var.site_config.use_32_bit_worker
      vnet_route_all_enabled = var.site_config.vnet_route_all_enabled
      websockets_enabled = var.site_config.websockets_enabled
      worker_count = var.site_config.worker_count
  }

  # dynamic "site_config" {
  #   for_each = var.site_config

  #   content {
  #     always_on = site_config.value.always_on # when running in a Consumption or Premium Plan, `always_on` feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
  #     api_definition_url = site_config.value.api_definition_url
  #     api_management_api_id = site_config.value.api_management_api_id
  #     app_command_line = site_config.value.app_command_line
  #     app_scale_limit = site_config.value.app_scale_limit
  #     application_insights_connection_string = site_config.value.application_insights_connection_string
  #     application_insights_key = site_config.value.application_insights_key

  #     dynamic "application_stack" {
  #       for_each = site_config.value.application_stack

  #       content {
  #         dotnet_version = application_stack.value.dotnet_version
  #         use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime
  #         java_version = application_stack.value.java_version
  #         node_version = application_stack.value.node_version
  #         powershell_core_version = application_stack.value.powershell_core_version
  #         use_custom_runtime = application_stack.value.use_custom_runtime
  #       }
  #     }

  #     dynamic "app_service_logs" {
  #       for_each = site_config.value.app_service_logs

  #       content {
          
  #       }
  #     }

  #     dynamic "cors" {
  #       for_each = site_config.value.cors

  #       content {
  #         allowed_origins = cors.value.allowed_origins
  #         support_credentials = cors.value.support_credentials
  #       }
  #     } #(Optional) A cors block as defined above.

  #     default_documents = site_config.value.default_documents #(Optional) Specifies a list of Default Documents for the Windows Function App.
  #     elastic_instance_minimum = site_config.value.elastic_instance_minimum #(Optional) The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
  #     ftps_state = site_config.value.ftps_state #(Optional) State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
  #     health_check_path = site_config.value.health_check_path #(Optional) The path to be checked for this Windows Function App health.
  #     health_check_eviction_time_in_min = site_config.value.health_check_eviction_time_in_min #(Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path.
  #     http2_enabled = site_config.value.http2_enabled #(Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to false.

  #     dynamic "ip_restriction" {
  #       for_each = site_config.value.ip_restriction

  #       content {
  #         action = ip_restriction.value.action
          
  #         dynamic "headers" {
  #           for_each = scm_ip_restriction.value.headers

  #           content {
  #             x_azure_fdid = headers.value.x_azure_fdid
  #             x_fd_health_probe = headers.value.x_fd_health_probe
  #             x_forwarded_for = headers.value.x_forwarded_for
  #             x_forwarded_host = headers.value.x_forwarded_host
  #           }
  #         }

  #         ip_address = scm_ip_restriction.value.ip_address
  #         name = scm_ip_restriction.value.name
  #         priority = scm_ip_restriction.value.priority
  #         service_tag = scm_ip_restriction.value.service_tag
  #         virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id

  #       }
  #     } #(Optional) One or more ip_restriction blocks as defined above.

  #     load_balancing_mode = site_config.value.load_balancing_mode #(Optional) The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests if omitted.
  #     managed_pipeline_mode = site_config.value.managed_pipeline_mode #(Optional) Managed pipeline mode. Possible values include: Integrated, Classic. Defaults to Integrated.
  #     minimum_tls_version = site_config.value.minimum_tls_version #(Optional) Configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
  #     # node_version = ""
  #     pre_warmed_instance_count = site_config.value.pre_warmed_instance_count #(Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
  #     remote_debugging_enabled = site_config.value.remote_debugging_enabled #(Optional) Should Remote Debugging be enabled. Defaults to false.
  #     remote_debugging_version = site_config.value.remote_debugging_version #(Optional) The Remote Debugging Version. Possible values include VS2017, VS2019, and VS2022.
  #     runtime_scale_monitoring_enabled = site_config.value.runtime_scale_monitoring_enabled #(Optional) Specifies if the runtime scale monitoring should be enabled. Defaults to false.
      
  #     dynamic "scm_ip_restriction" { # one or more scm_ip_restriction blocks 
  #       for_each = site_config.value.scm_ip_restriction

  #       content {
  #         action = scm_ip_restriction.value.action
          
  #         dynamic "headers" {
  #           for_each = scm_ip_restriction.value.headers

  #           content {
  #             x_azure_fdid = headers.value.x_azure_fdid
  #             x_fd_health_probe = headers.value.x_fd_health_probe
  #             x_forwarded_for = headers.value.x_forwarded_for
  #             x_forwarded_host = headers.value.x_forwarded_host
  #           }
  #         }

  #         ip_address = scm_ip_restriction.value.ip_address
  #         name = scm_ip_restriction.value.name
  #         priority = scm_ip_restriction.value.priority
  #         service_tag = scm_ip_restriction.value.service_tag
  #         virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
  #       }
  #     }

  #     scm_minimum_tls_version = site_config.value.scm_minimum_tls_version
  #     scm_use_main_ip_restriction = site_config.value.scm_use_main_ip_restriction
  #     use_32_bit_worker = site_config.value.use_32_bit_worker
  #     vnet_route_all_enabled = site_config.value.vnet_route_all_enabled
  #     websockets_enabled = site_config.value.websockets_enabled
  #     worker_count = site_config.value.worker_count

  #   }
    
  # }

  dynamic "storage_account" {
    for_each = var.storage_accounts

    content {
      access_key = storage_account.value.access_key
      account_name = storage_account.value.account_name
      name = storage_account.value.name
      share_name = storage_account.value.share_name
      type = storage_account.value.type
      mount_path = storage_account.value.mount_path
    }
  }

  dynamic "sticky_settings" {
    for_each = var.sticky_settings

    content {
      app_setting_names = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
    
  }
  
  storage_account_access_key = var.storage_account_access_key != null && var.storage_uses_managed_identity != true ? var.storage_account_access_key : null
  storage_account_name       = var.storage_account_name
  storage_uses_managed_identity = var.storage_uses_managed_identity == true && var.storage_account_access_key == null ? var.storage_uses_managed_identity : null
  storage_key_vault_secret_id = var.storage_key_vault_secret_id
  tags = var.tags
  virtual_network_subnet_id = var.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file = var.zip_deploy_file
}

# resource "azurerm_windows_function_app" "this" {
#   count = var.os_type == "Windows" ? 1 : 0

#   name                = var.name 
#   resource_group_name = var.resource_group_name
#   location            = coalesce(var.location)
#   service_plan_id            = var.service_plan_resource_id
#   app_settings = var.app_settings
#   key_vault_reference_identity_id = var.key_vault_reference_identity_id

#   site_config {

#     dynamic "application_stack" {
#       for_each = var.site_config.application_stack

#       content {
#         dotnet_version = application_stack.value.dotnet_version != null ? application_stack.value.dotnet_version : null
#         use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime != null ? application_stack.value.use_dotnet_isolated_runtime : null
#         java_version = application_stack.value.java_version != null ? application_stack.value.java_version : null
#         node_version = application_stack.value.node_version != null ? application_stack.value.node_version : null
#         powershell_core_version = application_stack.value.powershell_core_version != null ? application_stack.value.powershell_core_version : null
#         use_custom_runtime = application_stack.value.use_custom_runtime == true ? application_stack.value.use_custom_runtime : null
#       }
#     }

#     dynamic "app_service_logs" {
#       for_each = var.site_config.app_service_logs

#       content {
#         disk_quota_mb = app_service_logs.value.disk_quota_mb
#         retention_period_days = app_service_logs.value.retention_period_days
#       }
#     }

#     dynamic "cors" {
#       for_each = var.site_config.cors

#       content {
#         allowed_origins = cors.value.allowed_origins
#         support_credentials = cors.value.support_credentials
#       }
#     }

#   }  
#     dynamic "sticky_settings" {
#       for_each = var.sticky_settings

#       content {
#         app_setting_names = sticky_settings.value.app_setting_names
#         connection_string_names = sticky_settings.value.connection_string_names
#       }
      
#     }
# }

resource "azurerm_linux_function_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = var.name 
  resource_group_name = var.resource_group_name
  location            = coalesce(var.location)

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  service_plan_id = var.service_plan_resource_id

  site_config {}

}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id
  lock_level = var.lock.kind
}
