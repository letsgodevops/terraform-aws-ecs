locals {
  alb_lb_name = var.internal_lb ? var.app_generic_config.ecs_cluster_config.internal_lb_arn_suffix : var.app_generic_config.ecs_cluster_config.external_lb_arn_suffix
}

locals {
  tg_application_name = var.override_tagret_group_name != null ? var.override_tagret_group_name : var.app_generic_config.application
  tagret_group_name   = format("%.32s", replace("${var.app_generic_config.environment}-${local.tg_application_name}${local.name_suffix}", "_", ""))
}
resource "aws_lb_target_group" "this" {
  count       = local.alb_count
  name        = local.tagret_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.app_generic_config.vpc_id

  // https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
  // https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/status"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "domain_routing" {
  count        = local.alb_count
  listener_arn = var.internal_lb ? var.app_generic_config.ecs_cluster_config.internal_lb_listener_arn : var.app_generic_config.ecs_cluster_config.external_lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }

  dynamic "condition" {
    for_each = var.alb_paths != null ? [true] : []
    content {
      path_pattern {
        values = var.alb_paths
      }
    }
  }
}

resource "aws_route53_record" "internal" {
  count   = var.internal_lb ? 1 : 0
  zone_id = var.app_generic_config.route53_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.app_generic_config.ecs_cluster_config.internal_lb_dns_name
    zone_id                = var.app_generic_config.ecs_cluster_config.internal_lb_zone_id
    evaluate_target_health = true
  }
}
resource "cloudflare_record" "exteranl" {
  count   = (var.external_lb && var.skip_domain_creation == false) ? 1 : 0
  zone_id = var.app_generic_config.cloudflare_zone_id
  name    = var.domain
  content = var.app_generic_config.ecs_cluster_config.external_lb_dns_name
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "aws_security_group_rule" "allow_http_alb" {
  count                    = var.skip_domain_creation == false ? local.alb_count : 0
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.internal_lb ? var.app_generic_config.ecs_cluster_config.internal_lb_security_group_id : var.app_generic_config.ecs_cluster_config.external_lb_security_group_id
  security_group_id        = var.app_generic_config.security_group_id
}

locals {
  // fix for: The given key does not identify an element in this collection value.
  target_group_arn_suffix = local.alb_enabled ? aws_lb_target_group.this[0].arn_suffix : ""
}

module "alb_alarms" {
  source  = "../cloudwatch-alarms/alb"
  enabled = local.alb_count > 0 ? true : false

  name                    = local.full_name
  target_group_arn_suffix = local.target_group_arn_suffix
  lb_arn_suffix           = var.internal_lb ? var.app_generic_config.ecs_cluster_config.internal_lb_arn_suffix : var.app_generic_config.ecs_cluster_config.external_lb_arn_suffix

  warning_sns_topic_arns  = var.warning_notifications
  critical_sns_topic_arns = var.critical_notifications

  target_response_time = var.alarm_target_response_time

  tags = local.tags
}
