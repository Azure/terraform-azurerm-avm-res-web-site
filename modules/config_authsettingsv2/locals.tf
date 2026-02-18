locals {
  # Build httpSettings using merge to avoid null forwardProxy key
  http_settings = merge(
    {
      requireHttps = var.require_https
      routes = {
        apiPrefix = var.http_route_api_prefix
      }
    },
    var.forward_proxy_convention != "NoProxy" ? {
      forwardProxy = {
        convention            = var.forward_proxy_convention
        customHostHeaderName  = var.forward_proxy_custom_host_header_name
        customProtoHeaderName = var.forward_proxy_custom_proto_header_name
      }
    } : {},
  )
  # Build identityProviders using merge to avoid null keys that cause idempotency issues
  identity_providers = var.identity_providers != null ? merge(
    var.identity_providers.apple != null ? {
      apple = {
        enabled = var.identity_providers.apple.enabled
        login   = var.identity_providers.apple.login
        registration = var.identity_providers.apple.registration != null ? {
          clientId                = var.identity_providers.apple.registration.client_id
          clientSecretSettingName = var.identity_providers.apple.registration.client_secret_setting_name
        } : null
      }
    } : {},
    var.identity_providers.azure_active_directory != null ? {
      azureActiveDirectory = merge(
        {
          enabled           = var.identity_providers.azure_active_directory.enabled
          isAutoProvisioned = var.identity_providers.azure_active_directory.is_auto_provisioned
          registration = var.identity_providers.azure_active_directory.registration != null ? {
            clientId                                      = var.identity_providers.azure_active_directory.registration.client_id
            clientSecretCertificateIssuer                 = var.identity_providers.azure_active_directory.registration.client_secret_certificate_issuer
            clientSecretCertificateSubjectAlternativeName = var.identity_providers.azure_active_directory.registration.client_secret_certificate_subject_alternative_name
            clientSecretCertificateThumbprint             = var.identity_providers.azure_active_directory.registration.client_secret_certificate_thumbprint
            clientSecretSettingName                       = var.identity_providers.azure_active_directory.registration.client_secret_setting_name
            openIdIssuer                                  = var.identity_providers.azure_active_directory.registration.open_id_issuer
          } : null
        },
        var.identity_providers.azure_active_directory.login != null ? {
          login = {
            disableWWWAuthenticate = var.identity_providers.azure_active_directory.login.disable_www_authenticate
            loginParameters        = var.identity_providers.azure_active_directory.login.login_parameters
          }
        } : {},
        var.identity_providers.azure_active_directory.validation != null ? {
          validation = {
            allowedAudiences = var.identity_providers.azure_active_directory.validation.allowed_audiences
            defaultAuthorizationPolicy = var.identity_providers.azure_active_directory.validation.default_authorization_policy != null ? {
              allowedApplications = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_applications
              allowedPrincipals = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals != null ? {
                groups     = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.groups
                identities = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.identities
              } : null
            } : null
            jwtClaimChecks = var.identity_providers.azure_active_directory.validation.jwt_claim_checks != null ? {
              allowedClientApplications = var.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_client_applications
              allowedGroups             = var.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_groups
            } : null
          }
        } : {},
      )
    } : {},
    var.identity_providers.azure_static_web_apps != null ? {
      azureStaticWebApps = {
        enabled = var.identity_providers.azure_static_web_apps.enabled
        registration = var.identity_providers.azure_static_web_apps.registration != null ? {
          clientId = var.identity_providers.azure_static_web_apps.registration.client_id
        } : null
      }
    } : {},
    var.identity_providers.custom_open_id_connect_providers != null ? {
      customOpenIdConnectProviders = {
        for k, v in var.identity_providers.custom_open_id_connect_providers : k => {
          enabled = v.enabled
          login = v.login != null ? {
            nameClaimType = v.login.name_claim_type
            scopes        = v.login.scopes
          } : null
          registration = v.registration != null ? {
            clientId = v.registration.client_id
            clientCredential = v.registration.client_credential != null ? {
              method                  = v.registration.client_credential.method
              clientSecretSettingName = v.registration.client_credential.client_secret_setting_name
            } : null
            openIdConnectConfiguration = v.registration.open_id_connect_configuration != null ? {
              authorizationEndpoint        = v.registration.open_id_connect_configuration.authorization_endpoint
              certificationUri             = v.registration.open_id_connect_configuration.certification_uri
              issuer                       = v.registration.open_id_connect_configuration.issuer
              tokenEndpoint                = v.registration.open_id_connect_configuration.token_endpoint
              wellKnownOpenIdConfiguration = v.registration.open_id_connect_configuration.well_known_open_id_configuration
            } : null
          } : null
        }
      }
    } : {},
    var.identity_providers.facebook != null ? {
      facebook = {
        enabled         = var.identity_providers.facebook.enabled
        graphApiVersion = var.identity_providers.facebook.graph_api_version
        login           = var.identity_providers.facebook.login
        registration = var.identity_providers.facebook.registration != null ? {
          appId                = var.identity_providers.facebook.registration.app_id
          appSecretSettingName = var.identity_providers.facebook.registration.app_secret_setting_name
        } : null
      }
    } : {},
    var.identity_providers.github != null ? {
      gitHub = {
        enabled = var.identity_providers.github.enabled
        login   = var.identity_providers.github.login
        registration = var.identity_providers.github.registration != null ? {
          clientId                = var.identity_providers.github.registration.client_id
          clientSecretSettingName = var.identity_providers.github.registration.client_secret_setting_name
        } : null
      }
    } : {},
    var.identity_providers.google != null ? {
      google = {
        enabled = var.identity_providers.google.enabled
        login   = var.identity_providers.google.login
        registration = var.identity_providers.google.registration != null ? {
          clientId                = var.identity_providers.google.registration.client_id
          clientSecretSettingName = var.identity_providers.google.registration.client_secret_setting_name
        } : null
        validation = var.identity_providers.google.validation != null ? {
          allowedAudiences = var.identity_providers.google.validation.allowed_audiences
        } : null
      }
    } : {},
    var.identity_providers.legacy_microsoft_account != null ? {
      legacyMicrosoftAccount = {
        enabled = var.identity_providers.legacy_microsoft_account.enabled
        login   = var.identity_providers.legacy_microsoft_account.login
        registration = var.identity_providers.legacy_microsoft_account.registration != null ? {
          clientId                = var.identity_providers.legacy_microsoft_account.registration.client_id
          clientSecretSettingName = var.identity_providers.legacy_microsoft_account.registration.client_secret_setting_name
        } : null
        validation = var.identity_providers.legacy_microsoft_account.validation != null ? {
          allowedAudiences = var.identity_providers.legacy_microsoft_account.validation.allowed_audiences
        } : null
      }
    } : {},
    var.identity_providers.twitter != null ? {
      twitter = {
        enabled = var.identity_providers.twitter.enabled
        registration = var.identity_providers.twitter.registration != null ? {
          consumerKey               = var.identity_providers.twitter.registration.consumer_key
          consumerSecretSettingName = var.identity_providers.twitter.registration.consumer_secret_setting_name
        } : null
      }
    } : {},
  ) : null
  # Build login section using merge to avoid null keys
  login = var.login != null ? merge(
    {
      allowedExternalRedirectUrls   = var.login.allowed_external_redirect_urls
      preserveUrlFragmentsForLogins = var.login.preserve_url_fragments_for_logins
    },
    var.login.cookie_expiration != null ? {
      cookieExpiration = {
        convention       = var.login.cookie_expiration.convention
        timeToExpiration = var.login.cookie_expiration.time_to_expiration
      }
    } : {},
    var.login.nonce != null ? {
      nonce = {
        nonceExpirationInterval = var.login.nonce.nonce_expiration_interval
        validateNonce           = var.login.nonce.validate_nonce
      }
    } : {},
    var.login.routes != null ? {
      routes = {
        logoutEndpoint = var.login.routes.logout_endpoint
      }
    } : {},
    var.login.token_store != null ? {
      tokenStore = merge(
        {
          enabled                    = var.login.token_store.enabled
          tokenRefreshExtensionHours = var.login.token_store.token_refresh_extension_hours
        },
        var.login.token_store.azure_blob_storage != null ? {
          azureBlobStorage = {
            sasUrlSettingName = var.login.token_store.azure_blob_storage.sas_url_setting_name
          }
        } : {},
        var.login.token_store.file_system != null ? {
          fileSystem = {
            directory = var.login.token_store.file_system.directory
          }
        } : {},
      )
    } : {},
  ) : null
}
