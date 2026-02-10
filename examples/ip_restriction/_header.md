# IP Restriction Rules

This example deploys a Windows Function App with IP restriction rules configured in `site_config.ip_restriction`.

It demonstrates how to restrict inbound traffic to specific sources using service tags, IP addresses, or virtual network subnets. The example allows traffic only from the Azure Portal service tag with a health probe header check, blocking all other inbound requests.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
