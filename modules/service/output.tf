output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "The name of the ECS service"
}

locals {
  imagedefinitions = var.internal_lb || var.ssh_enabled || var.external_lb ? "imagedefinitions.json" : "imagedefinitions-php-fpm.json"
}

output "ecs_deployment_configuration" {
  description = "The ECS deployment configuration used by CodePipeline"
  value = {
    ClusterName = var.app_generic_config.ecs_cluster_config.id
    FileName    = var.custom_imagedefinitions != null ? var.custom_imagedefinitions : local.imagedefinitions
    ServiceName = aws_ecs_service.this.name
  }
}

output "internal_fqdn" {
  description = "The FQDN of internal route53 record"
  value       = (var.internal_lb && var.skip_domain_creation == false) ? aws_route53_record.internal[0].fqdn : ""
}

output "external_url" {
  description = "The external URL of the service"
  value       = (var.external_lb && var.skip_domain_creation == false) ? cloudflare_record.exteranl[0].hostname : null
}

output "monitoring" {
  description = "CloudWatch dashboard and alarms for the ECS service"
  value = {
    widgets = module.dashboard.widgets
    alarms  = local.alarms
  }
}



output "schedule_config" {
  value = {
    cluster_arn           = var.app_generic_config.ecs_cluster_config.arn
    task_definition_arn   = aws_ecs_task_definition.this.arn_without_revision
    container_name        = var.container_name
    private_subnet_ids    = var.app_generic_config.private_subnet_ids
    public_subnet_ids     = var.app_generic_config.public_subnet_ids
    security_group_id     = var.app_generic_config.security_group_id
    schedule_group        = aws_scheduler_schedule_group.this.name
    scheduler_role_arn    = aws_iam_role.scheduler.arn
    scheduler_dlq_pattern = local.scheduler_dlq_pattern
  }
}
