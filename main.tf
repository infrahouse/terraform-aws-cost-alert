resource "random_string" "alert-suffix" {
  length  = 6
  special = false
}

resource "aws_cloudwatch_metric_alarm" "periodic_cost" {
  alarm_name          = "periodic_cost_${random_string.alert-suffix.result}"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cost_threshold
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  metric_query {
    id = "m1"
    metric {
      metric_name = "EstimatedCharges"
      namespace   = "AWS/Billing"
      period      = var.period * 24 * 3600
      stat        = "Maximum"
      dimensions = {
        "Currency" = "USD"
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "RATE(m1) * ${var.period} * 24 * 3600"
    label       = var.period == 1 ? "Daily cost" : "Cost per ${var.period} days."
    return_data = true
  }

  alarm_actions = [
    aws_sns_topic.cost_notifications.arn
  ]
}

resource "aws_sns_topic" "cost_notifications" {
  name_prefix = "cost-periodic-"
}

resource "aws_sns_topic_subscription" "cost_emails" {
  endpoint  = var.notification_email
  protocol  = "email"
  topic_arn = aws_sns_topic.cost_notifications.arn
}
