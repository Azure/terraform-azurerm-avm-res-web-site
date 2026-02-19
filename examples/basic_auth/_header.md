# Authentication Settings

This example deploys a Windows Function App with authentication configured using both `auth_settings` (v1) and `auth_settings_v2` (v2) blocks.

It demonstrates how to set up Azure Active Directory SSO with the App Service's built-in authentication/authorization feature (Easy Auth). The FTPS state is set to `FtpsOnly` for secure file transfer.

> **Note:** If you have Azure policies that deny or audit App Services using basic/local authentication, be aware that the configuration may not persist.

The example uses `kind = "functionapp"` and `os_type = "Windows"`.
