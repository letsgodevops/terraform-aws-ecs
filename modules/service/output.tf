output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

locals {
  imagedefinitions = var.internal_lb || var.ssh_enabled || var.external_lb ? "imagedefinitions.json" : "imagedefinitions-php-fpm.json"
}

output "ecs_deployment_configuration" {
  value = {
    ClusterName = var.app_generic_config.ecs_cluster_config.id
    FileName    = var.custom_imagedefinitions != null ? var.custom_imagedefinitions : local.imagedefinitions
    ServiceName = aws_ecs_service.this.name
  }
}

output "internal_fqdn" {
  value = (var.internal_lb && var.skip_domain_creation == false) ? aws_route53_record.internal[0].fqdn : ""
}

output "external_url" {
  value = (var.external_lb && var.skip_domain_creation == false) ? cloudflare_record.exteranl[0].hostname : null
}

output "monitoring" {
  value = {
    widgets = module.dashboard.widgets
    alarms  = local.alarms
  }
}
