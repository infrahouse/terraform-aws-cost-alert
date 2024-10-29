# terraform-aws-cost-alert

The module creates a CloudWatch alert to monitor daily (or more) cost.
The notifications are sent to an email.

The module requires billing alerts 
that have to be [enabled explicitly](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html#turning_on_billing_metrics).

The module must be deployed in us-east-1 because the billing metric is maintained 
in this region.

When the alert is created, check your inbox - AWS will send a subscription confirmation request.
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.56 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.56 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.periodic_cost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic.cost_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.cost_emails](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [random_string.alert-suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cost_threshold"></a> [cost\_threshold](#input\_cost\_threshold) | Notify if cost per period is greater than this value | `number` | n/a | yes |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | Email that will receive alert notifications. | `string` | n/a | yes |
| <a name="input_period"></a> [period](#input\_period) | Evaluation period in days. The alert sums up cost per this period and notifies if this amount is greater than var.cost\_threshold. | `number` | `1` | no |

## Outputs

No outputs.
