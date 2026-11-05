$ErrorActionPreference = 'Stop'

# This runs before Avm.Authoring's authentication preflight, which otherwise
# permits Azure CLI. It prepares no infrastructure and obtains no tokens.
if ($env:GITHUB_ACTIONS -cne 'true' -or
    $env:GITHUB_REPOSITORY -cne 'Azure/terraform-azurerm-avm-res-web-site' -or
    $env:ARM_USE_OIDC -ine 'true') {
    throw 'Issue #422 integration tests run only in repository CI with its managed OIDC identity.'
}

foreach ($name in @(
        'ARM_CLIENT_ID', 'ARM_TENANT_ID', 'ARM_SUBSCRIPTION_ID',
        'ACTIONS_ID_TOKEN_REQUEST_URL', 'ACTIONS_ID_TOKEN_REQUEST_TOKEN',
        'GITHUB_STEP_SUMMARY'
    )) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
        throw "The managed integration job must provide $name."
    }
}

foreach ($name in @(
        'ARM_CLIENT_SECRET', 'ARM_CLIENT_SECRET_FILE_PATH',
        'ARM_CLIENT_CERTIFICATE', 'ARM_CLIENT_CERTIFICATE_PATH',
        'ARM_OIDC_TOKEN', 'ARM_OIDC_TOKEN_FILE_PATH', 'AZURE_FEDERATED_TOKEN_FILE'
    )) {
    if (-not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
        throw "Refusing alternate credentials from $name; use the managed job's OIDC request."
    }
}
