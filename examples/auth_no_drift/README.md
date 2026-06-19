# Auth No-Drift POC — `Azure/avm-res-web-site/azurerm` v0.15.1

> **Purpose:** Proof-of-concept showing how to configure Azure AD
> authentication on an App Service using the AVM web-site module at version
> `0.15.1` **without any token or credential drift** on subsequent
> `terraform plan` runs.

---

## Problem This POC Solves

Three patterns cause **perpetual drift** — a diff on every `terraform plan`
even when nothing has changed:

| # | Pattern | Root Cause |
|---|---------|-----------|
| 1 | `random_integer` without `keepers` | Max range changes when region list grows → new random → all resources recreated |
| 2 | App Insights token fed directly as app setting | Live token changes when key rotates → Terraform detects diff → updates web app |
| 3 | `auth_settings_v2` without explicit `client_secret_setting_name` | Azure auto-fills the secret name on first deploy; next plan sees `null` vs auto-filled value |

---

## Architecture

```
Terraform Config
  │
  ├─ random_integer (keepers: region list fingerprint) ─── FROZEN
  │
  ├─ azurerm_key_vault_secret: appinsights-connection-string
  │    lifecycle { ignore_changes = [value] }  ─────────── FROZEN after write
  │
  └─ azurerm_key_vault_secret: aad-client-secret
       lifecycle { ignore_changes = [value] }  ─────────── FROZEN after write
           │
           │  Key Vault references (STATIC strings, never change)
           ▼
  App Service app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=...)"
    "AAD_CLIENT_SECRET"                     = "@Microsoft.KeyVault(SecretUri=...)"
  }
           │
           │  auth_settings_v2 references app setting by KEY NAME
           ▼
  auth_settings_v2 {
    client_secret_setting_name = "AAD_CLIENT_SECRET"  ← STATIC string
  }
```

---

## Four Drift-Prevention Rules

### Rule 1 — `random_integer` with `keepers`
```hcl
resource "random_integer" "region_index" {
  keepers = { regions_fingerprint = join(",", local.azure_regions) }
}
```
Only regenerates when the region list intentionally changes. Same list → same integer → no drift.

### Rule 2 — App Insights via Key Vault reference
```hcl
resource "azurerm_key_vault_secret" "appinsights_connstr" {
  lifecycle { ignore_changes = [value] }   # frozen after first write
}
app_settings = {
  "APPLICATIONINSIGHTS_CONNECTION_STRING" =
    "@Microsoft.KeyVault(SecretUri=${...versionless_id})"  # STATIC URI
}
```
The URI never changes. Azure resolves the live value at runtime. No drift.

### Rule 3 — Auth secret via `client_secret_setting_name`
```hcl
registration = {
  client_secret_setting_name = "AAD_CLIENT_SECRET"  # KEY NAME, not value
}
```
Terraform manages a static string. The actual secret lives in Key Vault.
No diff on any subsequent plan.

### Rule 4 — All `login` fields explicitly declared
```hcl
login = {
  token_store = { enabled = true, token_refresh_extension_hours = 72 }
  nonce       = { nonce_expiration_interval = "00:05:00", validate_nonce = true }
  preserve_url_fragments_for_logins = false
}
```
Prevents Azure from auto-populating defaults that Terraform would then
see as `null` → value diffs.

---

## Usage

```bash
# 1. Copy and fill example vars
cp terraform.tfvars.example terraform.tfvars
# Edit: aad_client_id, aad_tenant_id, aad_client_secret

# 2. Initialize
terraform init

# 3. First apply
terraform apply

# 4. Verify zero drift
terraform plan
# Expected: "No changes. Your infrastructure matches the configuration."
```

---

## Files

| File | Purpose |
|------|---------|
| `terraform.tf` | Provider versions for module v0.15.1 |
| `locals.tf` | Static pinned region list |
| `variables.tf` | Input vars — secrets come in statically, never from resource outputs |
| `main.tf` | All resources with drift-fix comments inline |
| `outputs.tf` | Key resource identifiers |
| `terraform.tfvars.example` | Example values — copy to `terraform.tfvars` |

---

## Module Version Info

**`Azure/avm-res-web-site/azurerm` `0.15.1`**

Required providers:
- `hashicorp/azurerm ~> 4.0, >= 4.21.1, < 5.0.0`
- `hashicorp/random >= 3.5.0, < 4.0.0`
