variable "cost_threshold" {
  description = "Notify if cost per period is greater than this value"
  type        = number
}


variable "period" {
  description = "Evaluation period in days. The alert sums up cost per this period and notifies if this amount is greater than var.cost_threshold."
  type        = number
  default     = 1
}

variable "notification_email" {
  description = "Email that will receive alert notifications."
  type        = string
}
