output "auto_heal_rules" {
  description = "ARM-format auto heal rules."
  value       = local.auto_heal_rules
}

output "has_identity" {
  description = "Whether an identity block should be configured."
  value       = local.has_identity
}

output "identity_block" {
  description = "ARM-format identity block."
  value       = local.identity_block
}

output "ip_security_restrictions" {
  description = "ARM-format IP security restrictions."
  value       = local.ip_security_restrictions
}

output "java_container" {
  description = "Java container value."
  value       = local.java_container
}

output "java_container_version" {
  description = "Java container version."
  value       = local.java_container_version
}

output "java_version" {
  description = "Java version."
  value       = local.java_version
}

output "linux_fx_version" {
  description = "Computed linuxFxVersion string."
  value       = local.linux_fx_version
}

output "net_framework_version" {
  description = "Computed .NET framework version."
  value       = local.net_framework_version
}

output "node_version" {
  description = "Node.js version."
  value       = local.node_version
}

output "php_version" {
  description = "PHP version."
  value       = local.php_version
}

output "powershell_version" {
  description = "PowerShell version."
  value       = local.powershell_version
}

output "python_version" {
  description = "Python version."
  value       = local.python_version
}

output "scm_ip_security_restrictions" {
  description = "ARM-format SCM IP security restrictions."
  value       = local.scm_ip_security_restrictions
}

output "windows_fx_version" {
  description = "Computed windowsFxVersion string."
  value       = local.windows_fx_version
}
