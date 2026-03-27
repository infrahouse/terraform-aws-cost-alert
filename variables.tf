variable "alert_name" {
  description = "Alert name"
  type        = string
  default     = "AWS daily cost"
}

variable "environment" {
  description = "Environment name (e.g., development, staging, production)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.environment))
    error_message = "environment must contain only lowercase letters, numbers, and underscores. Got: ${var.environment}"
  }
}

variable "cost_threshold" {
  description = "Notify if estimated daily cost is greater than this value."
  type        = number

  validation {
    condition     = var.cost_threshold > 0
    error_message = "cost_threshold must be a positive number. Got: ${var.cost_threshold}"
  }
}

variable "notification_email" {
  description = "Email that will receive alert notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.notification_email))
    error_message = "notification_email must be a valid email address. Got: ${var.notification_email}"
  }
}

variable "period_hours" {
  description = <<-EOT
    Evaluation period in hours. Must evenly divide 24.
    Valid values: 1, 2, 3, 4, 6, 8, 12, 24.
  EOT
  type        = number
  default     = 12

  validation {
    condition     = contains([1, 2, 3, 4, 6, 8, 12, 24], var.period_hours)
    error_message = "period_hours must evenly divide 24. Valid values: 1, 2, 3, 4, 6, 8, 12, 24. Got: ${var.period_hours}"
  }
}
