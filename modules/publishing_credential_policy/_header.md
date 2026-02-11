# publishing_credential_policy submodule

This submodule manages basic publishing credential policies (`Microsoft.Web/sites/basicPublishingCredentialsPolicies`) for an Azure App Service site.

It can be used independently to configure FTP and SCM publishing credential policies on an existing site. Uses a single resource that handles both `ftp` and `scm` policy types via the `name` variable.
