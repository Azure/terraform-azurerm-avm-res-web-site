# Sensitive variables for demonstration purposes
# In production, these should come from Azure Key Vault, environment variables, or secure CI/CD secrets

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "production_api_key" {
  type        = string
  default     = "production-api-key-def456uvw012"
  description = "API key for third-party service in production (marked as sensitive)"
  sensitive   = true
}

variable "production_database_connection_string" {
  type        = string
  default     = "Server=tcp:prod-db.database.windows.net,1433;Database=mydb;User ID=admin;Password=Pr0duct10nP@ssw0rd!;Encrypt=true;"
  description = "Database connection string for the production environment (marked as sensitive)"
  sensitive   = true
}

variable "production_storage_key" {
  type        = string
  default     = "DefaultEndpointsProtocol=https;AccountName=prodstg;AccountKey=FAKE_STORAGE_KEY_EXAMPLE_DO_NOT_USE_IN_PRODUCTION==;EndpointSuffix=core.windows.net"
  description = "Storage account key for production (marked as sensitive)"
  sensitive   = true
}

variable "staging_api_key" {
  type        = string
  default     = "staging-api-key-abc123xyz789"
  description = "API key for third-party service in staging (marked as sensitive)"
  sensitive   = true
}

variable "staging_database_connection_string" {
  type        = string
  default     = "Server=tcp:staging-db.database.windows.net,1433;Database=mydb;User ID=admin;Password=StagingP@ssw0rd!;Encrypt=true;"
  description = "Database connection string for the staging environment (marked as sensitive)"
  sensitive   = true
}
