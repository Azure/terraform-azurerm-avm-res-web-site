# AVM Interfaces (Private Endpoints, Diagnostics, Managed Identity)

This example deploys a Windows Function App demonstrating the standard AVM interface patterns: managed identities, private endpoints, diagnostic settings, and Application Insights.

It shows how to:
- Enable system-assigned and user-assigned managed identities via `managed_identities`
- Create private endpoints with private DNS zone integration via `private_endpoints`
- Configure diagnostic settings to send logs to a Log Analytics workspace via `diagnostic_settings`
- Have the module create and configure Application Insights via `application_insights`
- Disable public network access with `public_network_access_enabled = false`

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
