# ZIP File Deployment

This example deploys a Function App with the application code deployed from a ZIP file using the `zip_deploy_file` variable.

ZIP deployment is a convenient way to push your application code to App Service directly from a local archive. The module handles uploading the ZIP file and configuring the app to run from it.

The example uses `kind = "functionapp"` with the `zip_deploy_file` configuration.
