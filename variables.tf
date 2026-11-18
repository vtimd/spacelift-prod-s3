variable "failure_mode" {
  description = "Run Observability demo switch. Set TF_VAR_failure_mode on the stack."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "slow", "http_timeout", "provider_timeout", "api_error"], var.failure_mode)
    error_message = "failure_mode must be one of: none, slow, http_timeout, provider_timeout, api_error."
  }
}
