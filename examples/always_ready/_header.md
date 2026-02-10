# Flex Consumption with Always Ready Instances

This example deploys a Linux Function App on the Azure Flex Consumption (FC1) plan with always-ready instances configured.

Always-ready instances keep a specified number of pre-warmed workers for designated trigger types (e.g., `http`, `blob`, `durable`), reducing cold-start latency for critical functions. This example demonstrates how to configure the `always_ready` variable to reserve instances for specific triggers.

The example uses `kind = "functionapp"`, `os_type = "Linux"`, and `function_app_uses_fc1 = true`.
