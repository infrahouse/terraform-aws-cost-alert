# Getting Started

## Prerequisites

1. **Terraform** >= 1.5
2. **AWS provider** >= 5.56, < 7.0
3. **Billing alerts enabled** in your AWS account:
   [Enable billing alerts](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html#turning_on_billing_metrics)

## First Deployment

### 1. Add the module to your Terraform configuration

The module **must** be deployed in `us-east-1`. If your default provider
uses a different region, create an aliased provider:

```hcl
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "cost_alert" {
  providers = {
    aws = aws.us-east-1
  }
  source             = "registry.infrahouse.com/infrahouse/cost-alert/aws"
  version            = "1.0.0"
  environment        = "production"
  cost_threshold     = 20
  notification_email = "your-email@example.com"
}
```

### 2. Apply

```bash
terraform init
terraform apply
```

### 3. Confirm the email subscription

After `terraform apply` completes, AWS sends a confirmation email to the
address you specified. **You must click the confirmation link** in that
email for notifications to work.

## Customizing the evaluation period

By default, the alarm evaluates every 12 hours. You can change this with
`period_hours`. Valid values are: 1, 2, 3, 4, 6, 8, 12, 24.

```hcl
module "cost_alert" {
  # ...
  period_hours = 24  # Evaluate once per day
}
```

A shorter period means faster detection but potentially noisier alerts
during cost spikes.
