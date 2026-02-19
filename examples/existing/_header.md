# Using Existing Application Insights

This example deploys a Linux Web App that references pre-existing Application Insights instances rather than having the module create them.

It demonstrates how to set `enable_application_insights = false` and instead pass Application Insights connection strings and instrumentation keys directly via `app_settings` and per-slot `site_config`. This is useful when you manage monitoring resources separately or need to share Application Insights across multiple services. A staging deployment slot is also configured with its own Application Insights instance.

The example uses `kind = "webapp"` and `os_type = "Linux"` with a .NET 8.0 application stack.
