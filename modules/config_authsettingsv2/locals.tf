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
  # Build identityProviders using merge to avoid null keys that cause idempotency issues.
  #
  # A nested object the caller has not supplied is emitted as an explicit `null`,
  # not omitted. `azapi_update_resource` reads the resource, merges the configured
  # body over it and writes the result back, so a key absent from `body` keeps
  # whatever Azure already held. Omission stops managing a property; it does not
  # clear it, and with `ignore_missing_property` on by default the orphaned remote
  # key is ignored on read, so a removed authorization policy would keep applying
  # under a clean plan (#378). Emitting the null is what gives a caller any way to
  # take a property back off.
  #
  # Verified provider-side: AzAPI's merge overwrites with an explicit null rather
  # than dropping it, so the null reaches Azure. NOT verified: what Azure then does
  # with it. No transition deployment — set a property, remove it, read it back —
  # has been run against a live site, so whether the null clears the stored value
  # or is ignored is unknown. See #382 for the module-wide limits of
  # `azapi_update_resource`.
  #
  # The two exceptions are `allowedPrincipals` and `jwtClaimChecks`, which carry
  # Azure's cleared shape instead. Those are the objects #368 reported drift on:
  # a GET returned them materialised with null members where the configuration
  # said `null`, and the two never reconciled. Sending the materialised shape
  # matches the response, so the plan converges, and it still names every member
  # the 2025-03-01 schema declares for them, so it remains a clearing value.
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
            # `defaultAuthorizationPolicy` itself stays a plain `null`, because no
            # report has shown Azure materialising it. It is the likeliest candidate
            # to need the cleared-shape treatment if one arrives: `jwtClaimChecks`
            # sits at the same depth and was observed materialising from a null in
            # #368. The remedy would be
            # `{ allowedApplications = null, allowedPrincipals = { groups = null, identities = null } }`,
            # which names every member the schema declares. Reaching for it now
            # would repeat #377's mistake of generalising from two confirmed cases.
            defaultAuthorizationPolicy = var.identity_providers.azure_active_directory.validation.default_authorization_policy != null ? {
              allowedApplications = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_applications
              # One of the two objects #368 observed Azure materialising on read.
              # Emitted with null members rather than as a bare `null`, so the
              # configuration matches the response and the plan converges, while
              # still naming both members `AllowedPrincipals` declares — a value
              # that clears rather than a key that stops being managed (#378).
              allowedPrincipals = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals != null ? {
                groups     = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.groups
                identities = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.identities
              } : { groups = null, identities = null }
            } : null
            # The other object #368 saw come back materialised with null members, so
            # send that shape. Same reasoning as `allowedPrincipals` above.
            jwtClaimChecks = var.identity_providers.azure_active_directory.validation.jwt_claim_checks != null ? {
              allowedClientApplications = var.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_client_applications
              allowedGroups             = var.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_groups
            } : { allowedClientApplications = null, allowedGroups = null }
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
