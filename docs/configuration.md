# Configuration

## Variables

### `environment` (required)

Environment name (e.g., `development`, `staging`, `production`).
Must contain only lowercase letters, numbers, and underscores.

```hcl
environment = "production"
```

### `cost_threshold` (required)

The estimated daily cost in USD that triggers the alarm.
Must be a positive number.

```hcl
cost_threshold = 20  # Alert if daily cost exceeds $20
```

### `notification_email` (required)

Email address that receives alarm notifications.
After deployment, you must confirm the subscription via the email AWS sends.

```hcl
notification_email = "alerts@example.com"
```

### `alert_name` (optional)

Name for the CloudWatch alarm. Useful for distinguishing alerts across
multiple accounts.

- **Default:** `"AWS daily cost"`

```hcl
alert_name = "[production]: AWS daily cost"
```

### `period_hours` (optional)

Evaluation period in hours. Controls how frequently the alarm checks
the estimated daily cost rate. Must evenly divide 24.

- **Default:** `12`
- **Valid values:** 1, 2, 3, 4, 6, 8, 12, 24

```hcl
period_hours = 24  # Check once per day
```

## Outputs

### `sns_topic_arn`

ARN of the SNS topic for cost alert notifications.
Useful if you want to add additional subscriptions (e.g., Slack, PagerDuty).

### `cloudwatch_alarm_arn`

ARN of the CloudWatch metric alarm.
Useful for referencing in dashboards or composite alarms.

## Example: Full Configuration

```hcl
module "cost_alert" {
  providers = {
    aws = aws.us-east-1
  }
  source             = "registry.infrahouse.com/infrahouse/cost-alert/aws"
  version            = "1.0.0"
  environment        = "production"
  alert_name         = "[infrahouse]: AWS daily cost"
  cost_threshold     = 18
  period_hours       = 24
  notification_email = "aleks@infrahouse.com"
}
```
