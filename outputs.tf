output "sns_topic_arn" {
  description = "ARN of the SNS topic for cost alert notifications."
  value       = aws_sns_topic.cost_notifications.arn
}

output "cloudwatch_alarm_arn" {
  description = "ARN of the CloudWatch metric alarm for daily cost."
  value       = aws_cloudwatch_metric_alarm.periodic_cost.arn
}
