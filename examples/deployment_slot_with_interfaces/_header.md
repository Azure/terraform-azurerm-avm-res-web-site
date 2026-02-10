# Deployment Slots with Interfaces

This example deploys a Windows Function App with multiple deployment slots, each configured with their own AVM interfaces.

It demonstrates per-slot Application Insights instances (via `slot_application_insights`), slot-level private endpoints with static IP configurations, and managed identities. The staging slot has public network access disabled and uses a dedicated private endpoint, while the development slot gets its own Application Insights instance created by the module.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
