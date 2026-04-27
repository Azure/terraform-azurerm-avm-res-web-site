output "expiration_date" {
  description = "The certificate's expiration date."
  value       = try(azapi_resource.this.output.properties.expirationDate, null)
}

output "issuer" {
  description = "The certificate issuer."
  value       = try(azapi_resource.this.output.properties.issuer, null)
}

output "key_vault_secret_status" {
  description = "The status of the Key Vault secret poll. Useful for diagnosing missing RBAC grants."
  value       = try(azapi_resource.this.output.properties.keyVaultSecretStatus, null)
}

output "name" {
  description = "The name of the certificate."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full resource object."
  sensitive   = true
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the certificate."
  value       = azapi_resource.this.id
}

output "subject_name" {
  description = "The certificate subject name."
  value       = try(azapi_resource.this.output.properties.subjectName, null)
}

output "thumbprint" {
  description = "The thumbprint of the certificate. Pass this value into `custom_domains[*].thumbprint` to bind the certificate to a hostname."
  value       = azapi_resource.this.output.properties.thumbprint
}
