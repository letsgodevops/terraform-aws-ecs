locals {
  alb_target_group = local.alb_count > 0 ? aws_lb_target_group.this.0.arn_suffix : ""
  alarms           = concat(module.alb_alarms.alarm_arns, module.ecs_alarms.alarm_arns)
}

module "dashboard" {
  source = "github.com/letsgodevops/terraform-aws-cloudwatch//modules/dashboards/ecs?ref=v0.0.4"

  section_name = "${var.app_generic_config.application}: ${var.role} @ ${var.app_generic_config.environment}"
  name         = "${var.container_name}:${var.app_generic_config.application}-${var.role}"

  cluster_id   = aws_ecs_service.this.cluster
  service_name = aws_ecs_service.this.name

  alb_target_group_arn = local.alb_count > 0 ? aws_lb_target_group.this.0.arn : null
}

module "ecs_alarms" {
  source = "../cloudwatch-alarms/ecs"

  create                       = var.create_ecs_alarms ? 1 : 0
  name                         = local.full_name
  cluster_name                 = var.app_generic_config.ecs_cluster_config.name
  service_name                 = aws_ecs_service.this.name
  cpu_utilization_threshold    = var.as_cpu_target + 10
  memory_utilization_threshold = var.as_memory_target + 10

  alarm_actions = var.warning_notifications
  ok_actions    = var.warning_notifications

  tags = local.tags
}
