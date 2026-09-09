data "azapi_resource_action" "app_settings" {
  type        = "Microsoft.Web/sites@2025-03-01"
  resource_id = module.avm_res_web_site.resource_id
  action      = "config/appsettings/list"
  method      = "POST"
  sensitive_response_export_values = [
    "properties.AzureWebJobsStorage",
    "properties.AzureWebJobsStorage__accountName",
    "properties.AzureWebJobsStorage__credential",
  ]

  lifecycle {
    postcondition {
      condition     = try(nonsensitive(self.sensitive_output.properties.AzureWebJobsStorage__accountName), null) == azapi_resource.storage_account.name
      error_message = "The deployed Function App must identify the host storage account through AzureWebJobsStorage__accountName."
    }
    postcondition {
      condition     = try(nonsensitive(self.sensitive_output.properties.AzureWebJobsStorage__credential), null) == "managedidentity"
      error_message = "The deployed Function App must configure AzureWebJobsStorage__credential as managedidentity."
    }
    postcondition {
      condition     = !can(self.sensitive_output.properties.AzureWebJobsStorage)
      error_message = "A new identity-based host storage deployment must not retain a plain AzureWebJobsStorage connection string."
    }
  }

  depends_on = [module.avm_res_web_site]
}
