module "cost_alert" {
  providers = {
    aws = aws.us-east-1
  }
  source  = "registry.infrahouse.com/infrahouse/cost-alert/aws"
  version = "1.1.1"

  environment        = "production"
  alert_name         = "[infrahouse]: AWS daily cost"
  cost_threshold     = 18
  period_hours       = 24
  notification_email = "aleks@infrahouse.com"
}
