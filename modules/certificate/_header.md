# certificate submodule

This submodule manages an App Service certificate
(`Microsoft.Web/certificates`). The certificate can either be sourced from
Azure Key Vault (recommended, supports auto-renewal) or uploaded inline as
a base64-encoded PFX blob.

The resulting `thumbprint` output is intended to be fed into the parent
module's `custom_domains[*].thumbprint` (or
`deployment_slots[*].custom_domains[*].thumbprint`) so the same plan can
provision the certificate **and** bind a hostname to it over SNI.

## Key Vault prerequisites

When sourcing the certificate from Key Vault, the well-known App Service
first-party service principal
**`abfa0a7c-a6b6-4736-8310-5855508787cd`** ("Microsoft Azure App Service")
must have read access to the certificate secret:

- For RBAC-enabled vaults: assign the **Key Vault Certificate User** role
  (`db79e9a7-68ee-4b58-9aeb-b90e7c24fcba`) on the vault scope.
- For access-policy-based vaults: grant `get` on `secrets` and
  `certificates`.

If the grant is missing the resource will deploy but
`key_vault_secret_status` will report the failure (e.g.
`KeyVaultSecretDoesNotExist`, `AccessDenied`).
