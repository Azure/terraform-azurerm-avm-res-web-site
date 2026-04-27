# Custom Domain and Deployment Slots

This example deploys a Windows Function App with custom domain bindings and multiple deployment slots (`qa` and `dev`).

It demonstrates how to use the `custom_domains` variable to bind custom hostnames to the App Service. The deployment slots are also configured with .NET 8.0 application stacks.

> **Note:** This module binds the hostname to the App Service but does **not** create the underlying DNS records or managed certificates. Before applying, ensure the required DNS records exist for each hostname – either a `CNAME` pointing to `<site-name>.azurewebsites.net`, or an `asuid.<custom-hostname>` `TXT` record containing the value of the module's `custom_domain_verification_id` output. DNS records can be managed with a separate module such as `Azure/avm-res-network-dnszone/azurerm`.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
