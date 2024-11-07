module "cost-alert" {
  source             = "../../"
  cost_threshold     = 18
  notification_email = "aleks@infrahouse.com"
}
