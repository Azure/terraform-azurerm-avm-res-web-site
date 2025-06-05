variable "app_service_active_slot" {
  type = object({
    slot_key                 = optional(string)
    overwrite_network_config = optional(bool, true)
  })
  default     = null
  description = <<DESCRIPTION

  ```
  Object that sets the active slot for the App Service.

  `slot_key` - The key of the slot object to set as active.
  `overwrite_network_config` - Determines if the network configuration should be overwritten. Defaults to `true`.

  ```
  DESCRIPTION
}

variable "deployment_slots" {
  type = map(object({
    name                                     = optional(string)
    app_settings                             = optional(map(string))
    builtin_logging_enabled                  = optional(bool, true)
    content_share_force_disabled             = optional(bool, false)
    client_affinity_enabled                  = optional(bool, false)
    client_certificate_enabled               = optional(bool, false)
    client_certificate_exclusion_paths       = optional(string, null)
    client_certificate_mode                  = optional(string, "Required")
    daily_memory_time_quota                  = optional(number, 0)
    enabled                                  = optional(bool, true)
    functions_extension_version              = optional(string, "~4")
    ftp_publish_basic_authentication_enabled = optional(bool, true)
    https_only                               = optional(bool, false)
    key_vault_reference_identity_id          = optional(string, null)
    # managed_identities = optional(object({
    #   system_assigned            = optional(bool, false)
    #   user_assigned_resource_ids = optional(set(string), [])
    # }), {})
    public_network_access_enabled                  = optional(bool, true)
    service_plan_id                                = optional(string, null)
    tags                                           = optional(map(string))
    virtual_network_subnet_id                      = optional(string, null)
    webdeploy_publish_basic_authentication_enabled = optional(bool, true)
    zip_deploy_file                                = optional(string, null)

    auth_settings = optional(map(object({
      additional_login_parameters    = optional(list(string))
      allowed_external_redirect_urls = optional(list(string))
      default_provider               = optional(string)
      enabled                        = optional(bool, false)
      issuer                         = optional(string)
      runtime_version                = optional(string)
      token_refresh_extension_hours  = optional(number, 72)
      token_store_enabled            = optional(bool, false)
      unauthenticated_client_action  = optional(string)
      active_directory = optional(map(object({
        client_id                  = optional(string)
        allowed_audiences          = optional(list(string))
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
      })))
      facebook = optional(map(object({
        app_id                  = optional(string)
        app_secret              = optional(string)
        app_secret_setting_name = optional(string)
        oauth_scopes            = optional(list(string))
      })))
      github = optional(map(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      })))
      google = optional(map(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      })))
      microsoft = optional(map(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      })))
      twitter = optional(map(object({
        consumer_key                 = optional(string)
        consumer_secret              = optional(string)
        consumer_secret_setting_name = optional(string)
      })))
    })), {})

    auth_settings_v2 = optional(map(object({
      auth_enabled                            = optional(bool, false)
      config_file_path                        = optional(string)
      default_provider                        = optional(string)
      excluded_paths                          = optional(list(string))
      forward_proxy_convention                = optional(string, "NoProxy")
      forward_proxy_custom_host_header_name   = optional(string)
      forward_proxy_custom_scheme_header_name = optional(string)
      http_route_api_prefix                   = optional(string, "/.auth")
      require_authentication                  = optional(bool, false)
      require_https                           = optional(bool, true)
      runtime_version                         = optional(string, "~1")
      unauthenticated_action                  = optional(string, "RedirectToLoginPage")
      active_directory_v2 = optional(map(object({
        allowed_applications                 = optional(list(string))
        allowed_audiences                    = optional(list(string))
        allowed_groups                       = optional(list(string))
        allowed_identities                   = optional(list(string))
        client_id                            = optional(string)
        client_secret_certificate_thumbprint = optional(string)
        client_secret_setting_name           = optional(string)
        jwt_allowed_client_applications      = optional(list(string))
        jwt_allowed_groups                   = optional(list(string))
        login_parameters                     = optional(map(any))
        tenant_auth_endpoint                 = optional(string)
        www_authentication_disabled          = optional(bool, false)
      })), {})
      apple_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        login_scopes               = optional(list(string))
      })), {})
      azure_static_web_app_v2 = optional(map(object({
        client_id = optional(string)
      })), {})
      custom_oidc_v2 = optional(map(object({
        authorisation_endpoint        = optional(string)
        certification_uri             = optional(string)
        client_credential_method      = optional(string)
        client_id                     = optional(string)
        client_secret_setting_name    = optional(string)
        issuer_endpoint               = optional(string)
        name                          = optional(string)
        name_claim_type               = optional(string)
        openid_configuration_endpoint = optional(string)
        scopes                        = optional(list(string))
        token_endpoint                = optional(string)
      })), {})
      facebook_v2 = optional(map(object({
        app_id                  = optional(string)
        app_secret_setting_name = optional(string)
        graph_api_version       = optional(string)
        login_scopes            = optional(list(string))
      })), {})
      github_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        login_scopes               = optional(list(string))
      })), {})
      google_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      })), {})
      login = map(object({
        allowed_external_redirect_urls    = optional(list(string))
        cookie_expiration_convention      = optional(string, "FixedTime")
        cookie_expiration_time            = optional(string, "00:00:00")
        logout_endpoint                   = optional(string)
        nonce_expiration_time             = optional(string, "00:05:00")
        preserve_url_fragments_for_logins = optional(bool, false)
        token_refresh_extension_time      = optional(number, 72)
        token_store_enabled               = optional(bool, false)
        token_store_path                  = optional(string)
        token_store_sas_setting_name      = optional(string)
        validate_nonce                    = optional(bool, true)
      }))
      microsoft_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      })), {})
      twitter_v2 = optional(map(object({
        consumer_key                 = optional(string)
        consumer_secret_setting_name = optional(string)
      })), {})
    })), {})

    auto_heal_setting = optional(map(object({
      action = optional(object({
        action_type = string
        custom_action = optional(object({
          executable = string
          parameters = optional(string)
        }))
        minimum_process_execution_time = optional(string, "00:00:00")
      }))
      trigger = optional(object({
        private_memory_kb = optional(number)
        requests = optional(map(object({
          count    = number
          interval = string
        })), {})
        slow_request = optional(map(object({
          count      = number
          interval   = string
          time_taken = string
          path       = optional(string)
        })), {})
        slow_request_with_path = optional(map(object({
          count      = number
          interval   = string
          time_taken = string
          path       = optional(string)
        })), {})
        status_code = optional(map(object({
          count             = number
          interval          = string
          status_code_range = string
          path              = optional(string)
          sub_status        = optional(number)
          win32_status_code = optional(number)
        })), {})
      }))
    })), {})

    backup = optional(map(object({
      enabled             = optional(bool, true)
      name                = optional(string)
      storage_account_url = optional(string)
      schedule = optional(map(object({
        frequency_interval       = optional(number)
        frequency_unit           = optional(string)
        keep_at_least_one_backup = optional(bool)
        retention_period_days    = optional(number)
        start_time               = optional(string)
      })))
    })), {})

    connection_strings = optional(map(object({
      name  = optional(string)
      type  = optional(string)
      value = optional(string)
    })), {})

    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)

    logs = optional(map(object({
      application_logs = optional(map(object({
        azure_blob_storage = optional(object({
          level             = optional(string, "Off")
          retention_in_days = optional(number, 0)
          sas_url           = string
        }))
        file_system_level = optional(string, "Off")
      })), {})
      detailed_error_messages = optional(bool, false)
      failed_request_tracing  = optional(bool, false)
      http_logs = optional(map(object({
        azure_blob_storage_http = optional(object({
          retention_in_days = optional(number, 0)
          sas_url           = string
        }))
        file_system = optional(object({
          retention_in_days = optional(number, 0)
          retention_in_mb   = number
        }))
      })), {})
    })), {})

    private_endpoints = optional(map(object({
      name = optional(string, null)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        principal_type                         = optional(string, null)
      })), {})
      lock = optional(object({
        kind = string
        name = optional(string, null)
      }), null)
      tags                                    = optional(map(string), null)
      subnet_resource_id                      = string
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string), [])
      application_security_group_associations = optional(map(string), {})
      private_service_connection_name         = optional(string, null)
      network_interface_name                  = optional(string, null)
      location                                = optional(string, null)
      resource_group_name                     = optional(string, null)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
      })), {})
    })), {})

    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})

    storage_shares_to_mount = optional(map(object({
      # access_key   = optional(string, null)
      account_name = string
      mount_path   = string
      name         = string
      share_name   = string
      type         = optional(string, "AzureFiles")
    })), {})

    site_config = optional(object({
      always_on                                     = optional(bool, true)
      api_definition_url                            = optional(string)
      api_management_api_id                         = optional(string)
      app_command_line                              = optional(string)
      auto_heal_enabled                             = optional(bool)
      app_scale_limit                               = optional(number)
      application_insights_connection_string        = optional(string)
      application_insights_key                      = optional(string)
      slot_application_insights_object_key          = optional(string)
      container_registry_managed_identity_client_id = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      default_documents                             = optional(list(string))
      elastic_instance_minimum                      = optional(number)
      ftps_state                                    = optional(string, "FtpsOnly")
      health_check_eviction_time_in_min             = optional(number)
      health_check_path                             = optional(string)
      http2_enabled                                 = optional(bool, false)
      ip_restriction_default_action                 = optional(string, "Allow")
      load_balancing_mode                           = optional(string, "LeastRequests")
      local_mysql_enabled                           = optional(bool, false)
      managed_pipeline_mode                         = optional(string, "Integrated")
      minimum_tls_version                           = optional(string, "1.3")
      pre_warmed_instance_count                     = optional(number)
      remote_debugging_enabled                      = optional(bool, false)
      remote_debugging_version                      = optional(string)
      runtime_scale_monitoring_enabled              = optional(bool)
      scm_ip_restriction_default_action             = optional(string, "Allow")
      scm_minimum_tls_version                       = optional(string, "1.2")
      scm_use_main_ip_restriction                   = optional(bool, false)
      use_32_bit_worker                             = optional(bool, false)
      vnet_route_all_enabled                        = optional(bool, false)
      websockets_enabled                            = optional(bool, false)
      worker_count                                  = optional(number)
      app_service_logs = optional(map(object({
        disk_quota_mb         = optional(number, 35)
        retention_period_days = optional(number)
      })), {})
      application_stack = optional(map(object({
        dotnet_core_version         = optional(string)
        dotnet_version              = optional(string)
        java_version                = optional(string)
        node_version                = optional(string)
        powershell_core_version     = optional(string)
        python_version              = optional(string)
        go_version                  = optional(string)
        ruby_version                = optional(string)
        java_server                 = optional(string)
        java_server_version         = optional(string)
        php_version                 = optional(string)
        use_custom_runtime          = optional(bool)
        use_dotnet_isolated_runtime = optional(bool)
        docker = optional(list(object({
          image_name        = string
          image_tag         = string
          registry_password = optional(string)
          registry_url      = string
          registry_username = optional(string)
        })))
        current_stack                = optional(string)
        docker_image_name            = optional(string)
        docker_registry_url          = optional(string)
        docker_registry_username     = optional(string)
        docker_registry_password     = optional(string)
        docker_container_name        = optional(string)
        docker_container_tag         = optional(string)
        java_embedded_server_enabled = optional(bool)
        tomcat_version               = optional(bool)
      })), {})
      cors = optional(map(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool, false)
      })), {})
      ip_restriction = optional(map(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(map(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string), ["1"])
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        })), {})
      })), {})
      scm_ip_restriction = optional(map(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(map(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string), ["1"])
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        })), {})
      })), {})
      virtual_application = optional(map(object({
        physical_path   = optional(string, "site\\wwwroot")
        preload_enabled = optional(bool, false)
        virtual_directory = optional(map(object({
          physical_path = optional(string)
          virtual_path  = optional(string)
        })), {})
        virtual_path = optional(string, "/")
        })),
        {
          default = {
            physical_path   = "site\\wwwroot"
            preload_enabled = false
            virtual_path    = "/"
          }
        }
      )
    }), {})

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }), null)

  }))
  default = {

  }
  description = <<DESCRIPTION

  ```
  > NOTE: If you plan to use the attribute reference of an external Application Insights instance for `application_insights_connection_string` and `application_insights_key`, you will likely need to remove the sensitivity level. For example, using the `nonsensitive` function.

  - `storage_shares_to_mount` - A map of storage shares to mount to the Function App deployment slot.
    - `name` - The name of the share.
    - `access_key` has been DEPRECATED and should not be used. Instead variable `slots_storage_shares_to_mount_sensitive_values` should be used.
    - `account_name` - The name of the Storage Account.
    - `share_name` - The name of the share in the Storage Account.
    - `mount_path` - The path where the share will be mounted in the Function App.
    - `type` - The type of mount, defaults to "AzureFiles".
  ```
  DESCRIPTION
}

variable "deployment_slots_inherit_lock" {
  type        = bool
  default     = true
  description = "Whether to inherit the lock from the parent resource for the deployment slots. Defaults to `true`."
}

variable "slot_application_insights" {
  type = map(object({
    application_type                      = optional(string, "web")
    inherit_tags                          = optional(bool, false)
    location                              = optional(string)
    name                                  = optional(string)
    resource_group_name                   = optional(string)
    tags                                  = optional(map(any), null)
    workspace_resource_id                 = optional(string)
    daily_data_cap_in_gb                  = optional(number)
    daily_data_cap_notifications_disabled = optional(bool)
    retention_in_days                     = optional(number, 90)
    sampling_percentage                   = optional(number, 100)
    disable_ip_masking                    = optional(bool, false)
    local_authentication_disabled         = optional(bool, false)
    internet_ingestion_enabled            = optional(bool, true)
    internet_query_enabled                = optional(bool, true)
    force_customer_storage_for_profiler   = optional(bool, false)
  }))
  default = {

  }
  description = <<DESCRIPTION
  Configures the Application Insights instance(s) for the deployment slot(s).
  ```
  DESCRIPTION
}

variable "slots_storage_shares_to_mount_sensitive_values" {
  type = map(string)
  default = {

  }
  description = <<DESCRIPTION
  A map of sensitive values (Storage Access Key) for the Storage Account SMB file shares to mount to the Function App.
  The key is the supplied input to `var.storage_shares_to_mount`.
  The value is the secret value (storage access key).
  DESCRIPTION
  sensitive   = true
}
