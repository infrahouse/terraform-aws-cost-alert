variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "role_arn" {
  description = "IAM role ARN to assume"
  type        = string
  default     = null
}
