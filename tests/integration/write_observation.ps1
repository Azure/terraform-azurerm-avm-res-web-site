$ErrorActionPreference = 'Stop'
if ($env:GITHUB_ACTIONS -cne 'true' -or
    $env:GITHUB_REPOSITORY -cne 'Azure/terraform-azurerm-avm-res-web-site' -or
    [string]::IsNullOrWhiteSpace($env:GITHUB_STEP_SUMMARY)) {
    throw 'Issue #422 observation reporting is CI-only.'
}

# Terraform passes only the selected subnet fields, never a full state or plan.
$observation = ConvertFrom-Json -InputObject $env:AVM_422_OBSERVATION
$json = ConvertTo-Json -InputObject $observation -Depth 5
Write-Output $json
Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value @(
    '### Issue #422 subnet observation'
    '```json'
    $json
    '```'
) -Encoding utf8
