# Deprecated but kept for backward compatibility.
# The ARM API uses flat property names (e.g. facebookAppId, microsoftAccountClientId)
# rather than nested objects. Properties for disabled providers are set to null
# and excluded by the azapi provider during serialization.
resource "azapi_resource" "this" {
  name      = "authsettings"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      enabled                     = var.enabled
      runtimeVersion              = var.runtime_version
      tokenStoreEnabled           = var.token_store_enabled
      tokenRefreshExtensionHours  = var.token_refresh_extension_hours
      unauthenticatedClientAction = var.unauthenticated_client_action
      issuer                      = var.issuer
      allowedExternalRedirectUrls = var.allowed_external_redirect_urls
      additionalLoginParams       = var.additional_login_parameters
      defaultProvider             = var.default_provider
      # Active Directory (Azure AD)
      clientId                = try(var.active_directory.client_id, null)
      allowedAudiences        = try(var.active_directory.allowed_audiences, null)
      clientSecret            = try(var.active_directory.client_secret, null)
      clientSecretSettingName = try(var.active_directory.client_secret_setting_name, null)
      # Facebook
      facebookAppId                = try(var.facebook.app_id, null)
      facebookAppSecret            = try(var.facebook.app_secret, null)
      facebookAppSecretSettingName = try(var.facebook.app_secret_setting_name, null)
      facebookOAuthScopes          = try(var.facebook.oauth_scopes, null)
      # GitHub
      gitHubClientId                = try(var.github.client_id, null)
      gitHubClientSecret            = try(var.github.client_secret, null)
      gitHubClientSecretSettingName = try(var.github.client_secret_setting_name, null)
      gitHubOAuthScopes             = try(var.github.oauth_scopes, null)
      # Google
      googleClientId                = try(var.google.client_id, null)
      googleClientSecret            = try(var.google.client_secret, null)
      googleClientSecretSettingName = try(var.google.client_secret_setting_name, null)
      googleOAuthScopes             = try(var.google.oauth_scopes, null)
      # Microsoft Account
      microsoftAccountClientId                = try(var.microsoft.client_id, null)
      microsoftAccountClientSecret            = try(var.microsoft.client_secret, null)
      microsoftAccountClientSecretSettingName = try(var.microsoft.client_secret_setting_name, null)
      microsoftAccountOAuthScopes             = try(var.microsoft.oauth_scopes, null)
      # Twitter
      twitterConsumerKey               = try(var.twitter.consumer_key, null)
      twitterConsumerSecret            = try(var.twitter.consumer_secret, null)
      twitterConsumerSecretSettingName = try(var.twitter.consumer_secret_setting_name, null)
    }
  }
  response_export_values = []
}
