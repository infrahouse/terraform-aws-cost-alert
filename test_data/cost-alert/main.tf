module "cost_alert" {
  source             = "../../"
  environment        = var.environment
  cost_threshold     = 18
  notification_email = "aleks@infrahouse.com"
}
