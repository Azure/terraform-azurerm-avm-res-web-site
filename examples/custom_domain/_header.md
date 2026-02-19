# Custom Domain and Deployment Slots

This example deploys a Windows Function App with custom domain bindings and multiple deployment slots (`qa` and `dev`).

It demonstrates how to use the `custom_domains` variable to configure custom hostnames, SSL certificates, DNS records (CNAME/TXT), and domain validation. The deployment slots are also configured with .NET 8.0 application stacks.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
