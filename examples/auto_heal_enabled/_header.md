# Auto Heal Settings

This example deploys a Linux Web App with auto heal enabled via the `auto_heal_enabled` and `auto_heal_rules` variables.

Auto heal automatically restarts your App Service based on configurable triggers such as request count thresholds, slow request durations, HTTP status code frequencies, or private memory usage. The example shows how to define both trigger conditions and the recovery action (e.g., `Recycle`, `LogEvent`, or `CustomAction`).

The example uses `kind = "webapp"` and `os_type = "Linux"`.
