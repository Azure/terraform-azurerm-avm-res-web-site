variable "app_service_active_slot" {
  type = object({
    slot_key                 = optional(string)
    overwrite_network_config = optional(bool, true)
  })
  default     = null
  description = <<DESCRIPTION

  ```

  ```
  DESCRIPTION
}

variable "deployment_slots" {
  type = map(object({
    name                                           = optional(string)
    app_settings                                   = optional(map(string))
    builtin_logging_enabled                        = optional(bool, true)
    content_share_force_disabled                   = optional(bool, false)
    client_affinity_enabled                        = optional(bool, false)
    client_certificate_enabled                     = optional(bool, false)
    client_certificate_exclusion_paths             = optional(string, null)
    client_certificate_mode                        = optional(string, "Required")
    daily_memory_time_quota                        = optional(number, 0)
    enabled                                        = optional(bool, true)
    functions_extension_version                    = optional(string, "~4")
    ftp_publish_basic_authentication_enabled       = optional(bool, true)
    https_only                                     = optional(bool, false)
    key_vault_reference_identity_id                = optional(string, null)
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
        requests = optional(object({
          count    = number
          interval = string
        }))
        slow_request = optional(map(object({
          count      = number
          interval   = string
          take_taken = string
          path       = optional(string)
        })), {})
        slow_request_with_path = optional(map(object({
          count      = number
          interval   = string
          take_taken = string
          path       = optional(string)
        })), {})
        status_code = optional(map(object({
          count             = number
          interval          = string
          status_code_range = number
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
      access_key   = string
      account_name = string
      mount_path   = string
      name         = string
      share_name   = string
      type         = optional(string, "AzureFiles")
    })), {})

    site_config = optional(object({
      always_on                                     = optional(bool, false) # when running in a Consumption or Premium Plan, `always_on` feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
      api_definition_url                            = optional(string)      # (Optional) The URL of the OpenAPI (Swagger) definition that provides schema for the function's HTTP endpoints.
      api_management_api_id                         = optional(string)      # (Optional) The API Management API identifier.
      app_command_line                              = optional(string)      # (Optional) The command line to launch the application.
      auto_heal_enabled                             = optional(bool)        # (Optional) Should auto-heal be enabled for the Function App?
      app_scale_limit                               = optional(number)      # (Optional) The maximum number of workers that the Function App can scale out to.
      application_insights_connection_string        = optional(string)      # (Optional) The connection string of the Application Insights resource to send telemetry to.
      application_insights_key                      = optional(string)      # (Optional) The instrumentation key of the Application Insights resource to send telemetry to.
      container_registry_managed_identity_client_id = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      default_documents                             = optional(list(string))            #(Optional) Specifies a list of Default Documents for the Windows Function App.
      elastic_instance_minimum                      = optional(number)                  #(Optional) The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
      ftps_state                                    = optional(string, "Disabled")      #(Optional) State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
      health_check_eviction_time_in_min             = optional(number)                  #(Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path.
      health_check_path                             = optional(string)                  #(Optional) The path to be checked for this Windows Function App health.
      http2_enabled                                 = optional(bool, false)             #(Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to false.
      ip_restriction_default_action                 = optional(string, "Allow")         #(Optional) The default action for IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
      load_balancing_mode                           = optional(string, "LeastRequests") #(Optional) The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests if omitted.
      local_mysql_enabled                           = optional(bool, false)             #(Optional) Should local MySQL be enabled. Defaults to false.
      managed_pipeline_mode                         = optional(string, "Integrated")    #(Optional) Managed pipeline mode. Possible values include: Integrated, Classic. Defaults to Integrated.
      minimum_tls_version                           = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
      pre_warmed_instance_count                     = optional(number)                  #(Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
      remote_debugging_enabled                      = optional(bool, false)             #(Optional) Should Remote Debugging be enabled. Defaults to false.
      remote_debugging_version                      = optional(string)                  #(Optional) The Remote Debugging Version. Possible values include VS2017, VS2019, and VS2022.
      runtime_scale_monitoring_enabled              = optional(bool)                    #(Optional) Should runtime scale monitoring be enabled.
      scm_ip_restriction_default_action             = optional(string, "Allow")         #(Optional) The default action for SCM IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
      scm_minimum_tls_version                       = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests to Kudu. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
      scm_use_main_ip_restriction                   = optional(bool, false)             #(Optional) Should the SCM use the same IP restrictions as the main site. Defaults to false.
      use_32_bit_worker                             = optional(bool, false)             #(Optional) Should the 32-bit worker process be used. Defaults to false.
      vnet_route_all_enabled                        = optional(bool, false)             #(Optional) Should all traffic be routed to the virtual network. Defaults to false.
      websockets_enabled                            = optional(bool, false)             #(Optional) Should Websockets be enabled. Defaults to false.
      worker_count                                  = optional(number)                  #(Optional) The number of workers for this Windows Function App. Only affects apps on an Elastic Premium plan.
      app_service_logs = optional(map(object({
        disk_quota_mb         = optional(number, 35)
        retention_period_days = optional(number)
      })), {})
      application_stack = optional(map(object({
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
      })), {}) #(Optional) A cors block as defined above.
      ip_restriction = optional(map(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(map(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(number)
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        })), {})
      })), {}) #(Optional) One or more ip_restriction blocks as defined above.
      scm_ip_restriction = optional(map(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(map(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(number)
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        })), {})
      })), {}) #(Optional) One or more scm_ip_restriction blocks as defined above.
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

  ```
  DESCRIPTION
}

variable "deployment_slots_inherit_lock" {
  type        = bool
  default     = true
  description = "Whether to inherit the lock from the parent resource for the deployment slots."

}