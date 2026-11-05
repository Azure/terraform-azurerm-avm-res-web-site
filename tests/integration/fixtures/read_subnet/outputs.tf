output "observation" {
  value       = local.observation
  description = "Fresh GET representation, separate from managed-resource state."
}

output "checked_subnet" {
  value       = local.subnet_value
  description = "Live subnet with the same check used by the positive test and negative control."

  precondition {
    condition = var.expect_detached == null ? true : (
      var.expect_detached ? local.detached : try(lower(local.subnet_value) == lower(var.subnet_id), false)
    )
    error_message = "Unexpected live subnet state: ${jsonencode(local.observation)}; expect_detached=${jsonencode(var.expect_detached)}."
  }
}
