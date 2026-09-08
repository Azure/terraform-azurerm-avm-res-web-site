# Avm.Authoring currently requires AzAPI in this provider-free helper while
# TFLint rejects the generated declaration as unused. Remove this override when
# Azure/azure-verified-modules-tools#104 is resolved.
rule "terraform_unused_required_providers" {
  enabled = false
}
