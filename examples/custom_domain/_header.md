# Custom Domain and Deployment Slots

This example deploys a Windows Function App with two deployment slots
(`qa` and `dev`) and binds a custom hostname to the main site **and** to
the `qa` slot, with the TLS certificate sourced from Key Vault via the
`certificate` submodule.

> **`.e2eignore` is set on this directory.** The default hostnames
> (`app.contoso.com`, `qa.contoso.com`) point at a domain we do **not**
> own, so the example is not run as part of the end-to-end test suite.
> The Terraform code is fully wired and `terraform plan` succeeds; only
> the runtime hostname-binding step against Azure will fail until the
> hostnames are pointed at a domain you control and a real PFX has been
> imported into the example's Key Vault.

## Steps demonstrated

The numbered steps below correspond to the comment banners in
[`main.tf`](./main.tf).

1. **Provision DNS records.** Azure validates ownership of the custom
   hostname when the binding is created. Either a `CNAME` for the
   hostname pointing at `<site-name>.azurewebsites.net` or a `TXT`
   record at `asuid.<custom-hostname>` containing the
   `custom_domain_verification_id` output must already resolve. This
   example does **not** create those records because we do not control
   the `contoso.com` zone; in your own deployment, manage them with
   `Azure/avm-res-network-dnszone/azurerm` or your existing DNS
   provider.

2. **Stand up Key Vault and import the PFX.** A
   `Microsoft.KeyVault/vaults` resource is provisioned with RBAC
   authorisation enabled. Before applying, the PFX must be imported as
   a Key Vault certificate (the management API doesn't support cert
   creation, so this step is performed out-of-band):

   ```sh
   az keyvault certificate import \
     --vault-name <kv-name> \
     --name <key_vault_certificate_secret_name> \
     --file ./app.contoso.com.pfx \
     --password <pfx-password>
   ```

   The `key_vault_certificate_secret_name` input controls the name
   used here and on the certificate submodule.

3. **Grant the App Service first-party SP read access.** App Service
   pulls the certificate as the well-known service principal
   `abfa0a7c-a6b6-4736-8310-5855508787cd` ("Microsoft Azure App
   Service"). The example assigns the **Key Vault Certificate User**
   role (`db79e9a7-68ee-4b58-9aeb-b90e7c24fcba`) on the vault scope
   to that SP, which is the minimum privilege required for cert pull
   and auto-renewal.

4. **Materialise the certificate and bind hostnames in one module call.**
   The root module exposes a `certificates` input that wraps the
   `Microsoft.Web/certificates` resource. Each entry in `custom_domains`
   (on the main site or a slot) can then reference the certificate by
   `certificate_key` rather than by raw `thumbprint`, so the example
   never has to call the certificate submodule directly. The thumbprint
   is plumbed through internally; `ssl_state` is set to `SniEnabled`
   for SNI-based TLS termination. An explicit `depends_on` on the role
   assignment ensures App Service can read the secret on first apply.

## Configuration

The hostnames and Key Vault certificate name are defined as `locals` at
the top of [`main.tf`](./main.tf) (just above Step 1) so they are easy
to spot and tweak:

| Local | Default | Purpose |
|-------|---------|---------|
| `custom_hostname` | `app.contoso.com` | Hostname bound to the main site. |
| `qa_slot_custom_hostname` | `qa.contoso.com` | Hostname bound to the `qa` slot. |
| `key_vault_certificate_secret_name` | `app-contoso-com` | Name of the certificate inside the Key Vault. |
