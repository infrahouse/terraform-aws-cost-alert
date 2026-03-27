# terraform-aws-cost-alert

Terraform module that creates a CloudWatch alarm to monitor AWS daily cost
and sends notifications to an email via SNS.

## Features

- CloudWatch metric alarm based on estimated daily cost rate
- SNS topic with encryption at rest for alert notifications
- Email subscription for cost alerts
- Configurable cost threshold and evaluation period

## Quick Start

```hcl
module "cost_alert" {
  providers = {
    aws = aws.us-east-1
  }
  source             = "registry.infrahouse.com/infrahouse/cost-alert/aws"
  version            = "1.0.0"
  environment        = "production"
  cost_threshold     = 18
  notification_email = "alerts@example.com"
}
```

## Prerequisites

- **Region**: Must be deployed in `us-east-1` (billing metrics only exist there)
- **Billing alerts**: Must be
  [enabled explicitly](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html#turning_on_billing_metrics)
- **Email confirmation**: After deployment, check inbox for SNS subscription
  confirmation

## Architecture

![Architecture](assets/architecture.svg)

## How It Works

The module uses the `AWS/Billing` `EstimatedCharges` metric and calculates
the estimated daily cost rate using `RATE(m1) * 3600 * 24`. When the
estimated daily cost exceeds the configured threshold, an alarm triggers
and sends a notification to the subscribed email via SNS.
