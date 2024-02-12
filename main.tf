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

  auth_settings_v2 {
    auth_enabled = ""
    runtime_version = ""
    config_file_path = ""
    require_authentication = ""
    unauthenticated_action = ""
    default_provider = ""
    excluded_paths = ""
    require_https = ""
    http_route_api_prefix = ""
    forward_proxy_convention = ""
    forward_proxy_custom_host_header_name = ""
    forward_proxy_custom_scheme_header_name = ""
    apple_v2 {
      client_id = ""
      client_secret_setting_name = ""
      login_scopes = ""
    }
    active_directory_v2 {
      client_id = ""
      tenant_auth_endpoint = ""
      client_secret_setting_name = ""
      client_secret_certificate_thumbprint = ""
      jwt_allowed_groups = ""
      jwt_allowed_client_applications = ""
      www_authentication_disabled = ""
      allowed_groups = ""
      allowed_identities = ""
      allowed_applications = ""
      login_parameters = ""
      allowed_audiences = ""
    }
    azure_static_web_app_v2 {
      client_id = ""
      
    }
    custom_oidc_v2 {
      name = ""
      client_id = ""
      openid_configuration_endpoint = ""
      name_claim_type = ""
      scopes = ""
      client_credential_method = ""
      client_secret_setting_name = "" # "${}_PROVIDER_AUTHENTICATION_SECRET"
      authorisation_endpoint = ""
      token_endpoint = ""
      issuer_endpoint = ""
      certification_uri = ""
    }
    facebook_v2 {
      app_id = ""
      app_secret_setting_name = ""
      graph_api_version = ""
      login_scopes = ""

    }
    github_v2 {
      client_id = ""
      client_secret_setting_name = ""
      login_scopes = ""
    }
    google_v2 {
      client_id = ""
      client_secret_setting_name = ""
      allowed_audiences = ""
      login_scopes = ""
      
    }
    microsoft_v2 {
      client_id = ""
      client_secret_setting_name = ""
      allowed_audiences = ""
      login_scopes = ""
    }
    twitter_v2 {
      consumer_key = ""
      consumer_secret_setting_name = ""
    }
    login {
      logout_endpoint = ""
      token_store_enabled = ""
      token_refresh_extension_time = ""
      token_store_path = ""
      token_store_sas_setting_name = ""
      preserve_url_fragments_for_logins = ""
      allowed_external_redirect_urls = ""
      cookie_expiration_convention = ""
      cookie_expiration_time = ""
      validate_nonce = ""
      nonce_expiration_time = ""
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

  builtin_logging_enabled = ""
  client_certificate_enabled = ""
  client_certificate_mode = ""
  client_certificate_exclusion_paths = ""

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name = connection_string.value.name
      type = connection_string.value.type
      value = connection_string.value.value
    }
  }

  content_share_force_disabled = ""
  daily_memory_time_quota = ""
  enabled = ""
  ftp_publish_basic_authentication_enabled = ""
  functions_extension_version = ""
  https_only = ""
  public_network_access_enabled = ""
  
  dynamic "identity" {
    for_each = var.identities 

    content {
      type = identity.value.type
      identity_ids = identity.value.identity_ids
    }
    
  }

  key_vault_reference_identity_id = ""

  dynamic "site_config" {
    for_each = var.site_config

    content {
      always_on = site_config.value.always_on # when running in a Consumption or Premium Plan, `always_on` feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
      api_definition_url = ""
      api_management_api_id = ""
      app_command_line = ""
      app_scale_limit = ""
      application_insights_connection_string = ""
      application_insights_key = ""

      dynamic "application_stack" {
        for_each = var.site_config

        content {
          
        }

      }

      dynamic "app_service_logs" {
        for_each = var.site_config

        content {
          
        }
      }

      dynamic "cors" {
        for_each = var.site_config

        content {
          
        }
      } #(Optional) A cors block as defined above.

      default_documents = "" #(Optional) Specifies a list of Default Documents for the Windows Function App.
      elastic_instance_minimum = "" #(Optional) The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
      ftps_state = "" #(Optional) State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
      health_check_path = "" #(Optional) The path to be checked for this Windows Function App health.
      health_check_eviction_time_in_min = "" #(Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path.
      http2_enabled = "" #(Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to false.

      dynamic "ip_restriction" {
        for_each = var.site_config

        content {
          
        }
      } #(Optional) One or more ip_restriction blocks as defined above.

      load_balancing_mode = "" #(Optional) The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests if omitted.
      managed_pipeline_mode = "" #(Optional) Managed pipeline mode. Possible values include: Integrated, Classic. Defaults to Integrated.
      minimum_tls_version = "" #(Optional) Configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
      # node_version = ""
      pre_warmed_instance_count = "" #(Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
      remote_debugging_enabled = "" #(Optional) Should Remote Debugging be enabled. Defaults to false.
      remote_debugging_version = "" #(Optional) The Remote Debugging Version. Possible values include VS2017, VS2019, and VS2022.
      runtime_scale_monitoring_enabled = ""
      
      dynamic "scm_ip_restriction" { # one or more scm_ip_restriction blocks 
        for_each = var.site_config

        content {
          
        }
      }

      scm_minimum_tls_version = ""
      scm_use_main_ip_restriction = ""
      use_32_bit_worker = ""
      vnet_route_all_enabled = ""
      websockets_enabled = ""
      worker_count = ""

    }
    
  }

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
  
  storage_account_access_key = var.storage_account_access_key
  storage_account_name       = var.storage_account_name
  storage_uses_managed_identity = var.storage_uses_managed_identity
  storage_key_vault_secret_id = var.storage_key_vault_secret_id
  tags = var.tags
  virtual_network_subnet_id = var.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file = var.zip_deploy_file
}

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
