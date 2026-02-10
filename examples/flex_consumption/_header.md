# Flex Consumption Function App

This example deploys a Linux Function App on the Azure Flex Consumption (FC1) plan.

The Flex Consumption plan offers serverless compute with per-execution billing, configurable instance memory, and automatic scaling. This example demonstrates the minimum configuration for a Flex Consumption deployment using `function_app_uses_fc1 = true`, including the required storage container endpoint and runtime settings.

The example uses `kind = "functionapp"` and `os_type = "Linux"`.
