# Deprecated but kept for backward compatibility.
# The ARM API uses flat property names (e.g. facebookAppId, microsoftAccountClientId)
# rather than nested objects.
resource "azapi_resource" "authsettings" {
  for_each = var.auth_settings

  name      = "authsettings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = merge(
      {
        enabled                     = each.value.enabled
        runtimeVersion              = each.value.runtime_version
        tokenStoreEnabled           = each.value.token_store_enabled
        tokenRefreshExtensionHours  = each.value.token_refresh_extension_hours
        unauthenticatedClientAction = each.value.unauthenticated_client_action
        issuer                      = each.value.issuer
        allowedExternalRedirectUrls = each.value.allowed_external_redirect_urls
        additionalLoginParams       = each.value.additional_login_parameters != null ? each.value.additional_login_parameters : null
        defaultProvider             = each.value.default_provider
      },
      # Active Directory (Azure AD) - flat properties
      length(each.value.active_directory) > 0 ? {
        clientId                = values(each.value.active_directory)[0].client_id
        allowedAudiences        = values(each.value.active_directory)[0].allowed_audiences
        clientSecret            = values(each.value.active_directory)[0].client_secret
        clientSecretSettingName = values(each.value.active_directory)[0].client_secret_setting_name
      } : {},
      # Facebook - flat properties
      length(each.value.facebook) > 0 ? {
        facebookAppId                = values(each.value.facebook)[0].app_id
        facebookAppSecret            = values(each.value.facebook)[0].app_secret
        facebookAppSecretSettingName = values(each.value.facebook)[0].app_secret_setting_name
        facebookOAuthScopes          = values(each.value.facebook)[0].oauth_scopes
      } : {},
      # GitHub - flat properties
      length(each.value.github) > 0 ? {
        gitHubClientId                = values(each.value.github)[0].client_id
        gitHubClientSecret            = values(each.value.github)[0].client_secret
        gitHubClientSecretSettingName = values(each.value.github)[0].client_secret_setting_name
        gitHubOAuthScopes             = values(each.value.github)[0].oauth_scopes
      } : {},
      # Google - flat properties
      length(each.value.google) > 0 ? {
        googleClientId                = values(each.value.google)[0].client_id
        googleClientSecret            = values(each.value.google)[0].client_secret
        googleClientSecretSettingName = values(each.value.google)[0].client_secret_setting_name
        googleOAuthScopes             = values(each.value.google)[0].oauth_scopes
      } : {},
      # Microsoft Account - flat properties
      length(each.value.microsoft) > 0 ? {
        microsoftAccountClientId                = values(each.value.microsoft)[0].client_id
        microsoftAccountClientSecret            = values(each.value.microsoft)[0].client_secret
        microsoftAccountClientSecretSettingName = values(each.value.microsoft)[0].client_secret_setting_name
        microsoftAccountOAuthScopes             = values(each.value.microsoft)[0].oauth_scopes
      } : {},
      # Twitter - flat properties
      length(each.value.twitter) > 0 ? {
        twitterConsumerKey               = values(each.value.twitter)[0].consumer_key
        twitterConsumerSecret            = values(each.value.twitter)[0].consumer_secret
        twitterConsumerSecretSettingName = values(each.value.twitter)[0].consumer_secret_setting_name
      } : {},
    )
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "authsettingsv2" {
  for_each = var.auth_settings_v2

  name      = "authsettingsV2"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = {
      platform = {
        enabled        = each.value.auth_enabled
        runtimeVersion = each.value.runtime_version
        configFilePath = each.value.config_file_path
      }
      globalValidation = {
        requireAuthentication       = each.value.require_authentication
        unauthenticatedClientAction = each.value.unauthenticated_action
        excludedPaths               = each.value.excluded_paths
      }
      httpSettings = {
        requireHttps = each.value.require_https
        routes = {
          apiPrefix = each.value.http_route_api_prefix
        }
        forwardProxy = each.value.forward_proxy_convention != "NoProxy" ? {
          convention            = each.value.forward_proxy_convention
          customHostHeaderName  = each.value.forward_proxy_custom_host_header_name
          customProtoHeaderName = each.value.forward_proxy_custom_scheme_header_name
        } : null
      }
      identityProviders = {
        azureActiveDirectory = length(each.value.active_directory_v2) > 0 ? {
          for k, v in each.value.active_directory_v2 : k => {
            enabled = true
            registration = {
              clientId                          = v.client_id
              clientSecretCertificateThumbprint = v.client_secret_certificate_thumbprint
              clientSecretSettingName           = v.client_secret_setting_name
              openIdIssuer                      = v.tenant_auth_endpoint
            }
            validation = {
              allowedAudiences = v.allowed_audiences
              jwtClaimChecks = {
                allowedClientApplications = v.jwt_allowed_client_applications
                allowedGroups             = v.jwt_allowed_groups
              }
            }
          }
        } : null
      }
      login = length(each.value.login) > 0 ? {
        for k, v in each.value.login : k => {
          tokenStore = {
            enabled                    = v.token_store_enabled
            tokenRefreshExtensionHours = v.token_refresh_extension_time
            fileSystem = v.token_store_path != null ? {
              directory = v.token_store_path
            } : null
            azureBlobStorage = v.token_store_sas_setting_name != null ? {
              sasUrlSettingName = v.token_store_sas_setting_name
            } : null
          }
          preserveUrlFragmentsForLogins = v.preserve_url_fragments_for_logins
          allowedExternalRedirectUrls   = v.allowed_external_redirect_urls
          cookieExpiration = {
            convention       = v.cookie_expiration_convention
            timeToExpiration = v.cookie_expiration_time
          }
          nonce = {
            validateNonce           = v.validate_nonce
            nonceExpirationInterval = v.nonce_expiration_time
          }
        }
      } : null
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
