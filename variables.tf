variable "alert_name" {
  description = "Alert name"
  type        = string
  default     = "AWS daily cost"
}

variable "cost_threshold" {
  description = "Notify if cost per period is greater than this value."
  type        = number
}

variable "notification_email" {
  description = "Email that will receive alert notifications."
  type        = string
}

variable "period_hours" {
  description = "Evaluation period in hours. The alert sums up cost per this period and notifies if this amount is greater than var.cost_threshold."
  type        = number
  default     = 12
}
