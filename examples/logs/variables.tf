variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "redundancy_for_testing" {
  type    = string
  default = "false"
}

variable "sku_for_testing" {
  type    = string
  default = "S1"
}
