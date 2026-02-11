resource "azapi_resource" "this" {
  name      = "authsettingsV2"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      platform = {
        enabled        = var.auth_enabled
        runtimeVersion = var.runtime_version
        configFilePath = var.config_file_path
      }
      globalValidation = {
        requireAuthentication       = var.require_authentication
        unauthenticatedClientAction = var.unauthenticated_action
        excludedPaths               = var.excluded_paths
      }
      httpSettings = {
        requireHttps = var.require_https
        routes = {
          apiPrefix = var.http_route_api_prefix
        }
        forwardProxy = var.forward_proxy_convention != "NoProxy" ? {
          convention            = var.forward_proxy_convention
          customHostHeaderName  = var.forward_proxy_custom_host_header_name
          customProtoHeaderName = var.forward_proxy_custom_scheme_header_name
        } : null
      }
      identityProviders = {
        azureActiveDirectory = length(var.active_directory_v2) > 0 ? {
          for k, v in var.active_directory_v2 : k => {
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
      login = length(var.login) > 0 ? {
        for k, v in var.login : k => {
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
  response_export_values = []
}
