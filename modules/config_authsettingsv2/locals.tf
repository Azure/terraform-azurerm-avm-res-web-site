locals {
  # Shorthands for the deepest path in the schema, so the merge below stays readable.
  aad                              = try(var.identity_providers.azure_active_directory, null)
  aad_default_authorization_policy = try(local.aad.validation.default_authorization_policy, null)
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
  # Every nested object is contributed by a conditional `merge` arm rather than
  # emitted as an explicit `null`. Azure materialises an absent sub-object on read
  # (`"allowedPrincipals": {"groups": null, "identities": null}`), so a configured
  # `null` never matches what comes back and the plan never converges (#368). A key
  # that is absent from `body` is not compared at all, which is what we want.
  identity_providers = var.identity_providers != null ? merge(
    var.identity_providers.apple != null ? {
      apple = merge(
        {
          enabled = var.identity_providers.apple.enabled
        },
        var.identity_providers.apple.login != null ? {
          login = var.identity_providers.apple.login
        } : {},
        var.identity_providers.apple.registration != null ? {
          registration = {
            clientId                = var.identity_providers.apple.registration.client_id
            clientSecretSettingName = var.identity_providers.apple.registration.client_secret_setting_name
          }
        } : {},
      )
    } : {},
    local.aad != null ? {
      azureActiveDirectory = merge(
        {
          enabled           = local.aad.enabled
          isAutoProvisioned = local.aad.is_auto_provisioned
        },
        local.aad.registration != null ? {
          registration = {
            clientId                                      = local.aad.registration.client_id
            clientSecretCertificateIssuer                 = local.aad.registration.client_secret_certificate_issuer
            clientSecretCertificateSubjectAlternativeName = local.aad.registration.client_secret_certificate_subject_alternative_name
            clientSecretCertificateThumbprint             = local.aad.registration.client_secret_certificate_thumbprint
            clientSecretSettingName                       = local.aad.registration.client_secret_setting_name
            openIdIssuer                                  = local.aad.registration.open_id_issuer
          }
        } : {},
        local.aad.login != null ? {
          login = {
            disableWWWAuthenticate = local.aad.login.disable_www_authenticate
            loginParameters        = local.aad.login.login_parameters
          }
        } : {},
        local.aad.validation != null ? {
          validation = merge(
            {
              allowedAudiences = local.aad.validation.allowed_audiences
            },
            local.aad_default_authorization_policy != null ? {
              defaultAuthorizationPolicy = merge(
                {
                  allowedApplications = local.aad_default_authorization_policy.allowed_applications
                },
                local.aad_default_authorization_policy.allowed_principals != null ? {
                  allowedPrincipals = {
                    groups     = local.aad_default_authorization_policy.allowed_principals.groups
                    identities = local.aad_default_authorization_policy.allowed_principals.identities
                  }
                } : {},
              )
            } : {},
            local.aad.validation.jwt_claim_checks != null ? {
              jwtClaimChecks = {
                allowedClientApplications = local.aad.validation.jwt_claim_checks.allowed_client_applications
                allowedGroups             = local.aad.validation.jwt_claim_checks.allowed_groups
              }
            } : {},
          )
        } : {},
      )
    } : {},
    var.identity_providers.azure_static_web_apps != null ? {
      azureStaticWebApps = merge(
        {
          enabled = var.identity_providers.azure_static_web_apps.enabled
        },
        var.identity_providers.azure_static_web_apps.registration != null ? {
          registration = {
            clientId = var.identity_providers.azure_static_web_apps.registration.client_id
          }
        } : {},
      )
    } : {},
    var.identity_providers.custom_open_id_connect_providers != null ? {
      customOpenIdConnectProviders = {
        for k, v in var.identity_providers.custom_open_id_connect_providers : k => merge(
          {
            enabled = v.enabled
          },
          v.login != null ? {
            login = {
              nameClaimType = v.login.name_claim_type
              scopes        = v.login.scopes
            }
          } : {},
          v.registration != null ? {
            registration = merge(
              {
                clientId = v.registration.client_id
              },
              v.registration.client_credential != null ? {
                clientCredential = {
                  method                  = v.registration.client_credential.method
                  clientSecretSettingName = v.registration.client_credential.client_secret_setting_name
                }
              } : {},
              v.registration.open_id_connect_configuration != null ? {
                openIdConnectConfiguration = {
                  authorizationEndpoint        = v.registration.open_id_connect_configuration.authorization_endpoint
                  certificationUri             = v.registration.open_id_connect_configuration.certification_uri
                  issuer                       = v.registration.open_id_connect_configuration.issuer
                  tokenEndpoint                = v.registration.open_id_connect_configuration.token_endpoint
                  wellKnownOpenIdConfiguration = v.registration.open_id_connect_configuration.well_known_open_id_configuration
                }
              } : {},
            )
          } : {},
        )
      }
    } : {},
    var.identity_providers.facebook != null ? {
      facebook = merge(
        {
          enabled         = var.identity_providers.facebook.enabled
          graphApiVersion = var.identity_providers.facebook.graph_api_version
        },
        var.identity_providers.facebook.login != null ? {
          login = var.identity_providers.facebook.login
        } : {},
        var.identity_providers.facebook.registration != null ? {
          registration = {
            appId                = var.identity_providers.facebook.registration.app_id
            appSecretSettingName = var.identity_providers.facebook.registration.app_secret_setting_name
          }
        } : {},
      )
    } : {},
    var.identity_providers.github != null ? {
      gitHub = merge(
        {
          enabled = var.identity_providers.github.enabled
        },
        var.identity_providers.github.login != null ? {
          login = var.identity_providers.github.login
        } : {},
        var.identity_providers.github.registration != null ? {
          registration = {
            clientId                = var.identity_providers.github.registration.client_id
            clientSecretSettingName = var.identity_providers.github.registration.client_secret_setting_name
          }
        } : {},
      )
    } : {},
    var.identity_providers.google != null ? {
      google = merge(
        {
          enabled = var.identity_providers.google.enabled
        },
        var.identity_providers.google.login != null ? {
          login = var.identity_providers.google.login
        } : {},
        var.identity_providers.google.registration != null ? {
          registration = {
            clientId                = var.identity_providers.google.registration.client_id
            clientSecretSettingName = var.identity_providers.google.registration.client_secret_setting_name
          }
        } : {},
        var.identity_providers.google.validation != null ? {
          validation = {
            allowedAudiences = var.identity_providers.google.validation.allowed_audiences
          }
        } : {},
      )
    } : {},
    var.identity_providers.legacy_microsoft_account != null ? {
      legacyMicrosoftAccount = merge(
        {
          enabled = var.identity_providers.legacy_microsoft_account.enabled
        },
        var.identity_providers.legacy_microsoft_account.login != null ? {
          login = var.identity_providers.legacy_microsoft_account.login
        } : {},
        var.identity_providers.legacy_microsoft_account.registration != null ? {
          registration = {
            clientId                = var.identity_providers.legacy_microsoft_account.registration.client_id
            clientSecretSettingName = var.identity_providers.legacy_microsoft_account.registration.client_secret_setting_name
          }
        } : {},
        var.identity_providers.legacy_microsoft_account.validation != null ? {
          validation = {
            allowedAudiences = var.identity_providers.legacy_microsoft_account.validation.allowed_audiences
          }
        } : {},
      )
    } : {},
    var.identity_providers.twitter != null ? {
      twitter = merge(
        {
          enabled = var.identity_providers.twitter.enabled
        },
        var.identity_providers.twitter.registration != null ? {
          registration = {
            consumerKey               = var.identity_providers.twitter.registration.consumer_key
            consumerSecretSettingName = var.identity_providers.twitter.registration.consumer_secret_setting_name
          }
        } : {},
      )
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
