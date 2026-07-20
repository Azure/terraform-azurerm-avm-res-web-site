variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Enable telemetry for the module."
}

variable "aad_client_id" {
  type        = string
  description = "Azure AD application (client) ID for Easy Auth."
}

variable "aad_client_secret" {
  type        = string
  description = "Azure AD client secret for Easy Auth (stored in Key Vault)."
  sensitive   = true
}

variable "aad_tenant_id" {
  type        = string
  description = "Azure AD tenant ID for the OpenID issuer URL."
}