locals {
  module_version = "1.0.0"

  module_name = "infrahouse/cost-alert/aws"
  default_module_tags = {
    environment : var.environment
    created_by_module : local.module_name
  }
}
