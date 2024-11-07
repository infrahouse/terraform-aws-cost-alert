resource "aws_cloudwatch_metric_alarm" "periodic_cost" {
  alarm_name          = var.alert_name
  alarm_description   = "Estimated daily cost."
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cost_threshold
  evaluation_periods  = 24 / var.period_hours
  datapoints_to_alarm = 24 / var.period_hours

  metric_query {
    id = "m1"
    metric {
      metric_name = "EstimatedCharges"
      namespace   = "AWS/Billing"
      period      = var.period_hours * 3600
      stat        = "Average"
      dimensions = {
        "Currency" = "USD"
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "RATE(m1) * 3600 * 24"
    label       = "Estimated Cost per Day"
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
