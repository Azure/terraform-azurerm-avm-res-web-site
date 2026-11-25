data "azapi_resource_action" "app_settings" {
  action                 = "config/appsettings/list"
  method                 = "POST"
  resource_id            = module.avm_res_web_site.resource_id
  type                   = "Microsoft.Web/sites@2025-03-01"
  response_export_values = []
  sensitive_response_export_values = [
    "properties.AzureWebJobsStorage",
    "properties.AzureWebJobsStorage__managedIdentityResourceId",
    "properties.AzureWebJobsStorage__credential",
  ]

  lifecycle {
    postcondition {
      condition     = lower(try(nonsensitive(self.sensitive_output.properties.AzureWebJobsStorage__managedIdentityResourceId), "")) == lower(azapi_resource.user_assigned_identity.id)
      error_message = "The deployed Logic App must select the user-assigned identity through AzureWebJobsStorage__managedIdentityResourceId."
    }
    postcondition {
      condition     = try(nonsensitive(self.sensitive_output.properties.AzureWebJobsStorage__credential), null) == "managedIdentity"
      error_message = "The deployed Logic App must configure AzureWebJobsStorage__credential as managedIdentity."
    }
    postcondition {
      condition     = !can(self.sensitive_output.properties.AzureWebJobsStorage)
      error_message = "A new identity-based host storage deployment must not have an AzureWebJobsStorage connection string."
    }
  }
  depends_on = [module.avm_res_web_site]
}
