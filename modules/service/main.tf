locals {
  generic_suffix = var.app_generic_config.project != null ? "-${var.app_generic_config.project}" : ""
  module_suffix  = var.add_suffix_to_name != null ? "-${var.add_suffix_to_name}" : ""
  name_suffix    = local.module_suffix != "" ? local.module_suffix : local.generic_suffix

  full_name    = "${var.app_generic_config.environment}-${var.app_generic_config.application}-${var.role}${local.name_suffix}"
  service_name = "${var.app_generic_config.environment}-${var.app_generic_config.application}${local.name_suffix}"

  alb_count   = var.internal_lb || var.external_lb ? 1 : 0
  alb_enabled = var.internal_lb || var.external_lb ? true : false

  tags = {
    Environment = var.app_generic_config.environment
    Application = var.app_generic_config.application
    Role        = var.role
    Name        = local.service_name
    Creator     = "Terraform"
  }

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-group"         = local.service_name
      "awslogs-stream-prefix" = var.role
    }
  }

  ecr_repo = var.app_generic_config.ecr_repo
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  ssh_port_mapping = var.ssh_enabled == false ? [] : [{
    containerPort = 22
    hostPort      = 22
    protocol      = "tcp"
  }]
  custom_mapping = [for pm in keys(var.custom_ports) : { containerPort = pm, hostPort = pm, protocol = "tcp" }]
  http_port_mapping = var.http_enabled == false ? [] : [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  healthcheck = var.health_check_cmd == null ? null : {
    command     = ["CMD-SHELL", var.health_check_cmd]
    interval    = 30
    timeout     = 5
    retries     = 2
    startPeriod = 10
  }
}
module "container_app" {
  source             = "../container"
  enabled            = true
  name               = var.container_name
  image              = "${local.ecr_repo}/${var.container_name}:latest"
  entrypoint         = var.entrypoint
  memory             = local.memory - module.container_nginx.memory
  memory_reservation = var.memory_reservation
  cpu                = local.cpu - module.container_nginx.cpu

  environment_variables = var.environment_variables
  secrets               = var.secret_variables
  log_configuration     = local.log_configuration

  port_mappings = flatten([local.custom_mapping, local.ssh_port_mapping, local.http_port_mapping])
  mount_points  = var.mount_points

  healthcheck = local.healthcheck
}

module "container_nginx" {
  source             = "../container"
  enabled            = local.alb_enabled && !var.http_enabled
  name               = "nginx"
  image              = "${local.ecr_repo}/nginx:latest"
  memory             = 512
  memory_reservation = 128
  cpu                = 256

  environment_variables = [
    {
      name  = "FPM_CONTAINER_NAME"
      value = "localhost"
    },
    {
      name  = "VIRTUAL_HOST"
      value = "localhost"
    },
  ]

  port_mappings = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }
  ]

  log_configuration = local.log_configuration
}

locals {
  container_definitions = format("[%s]", join(",", compact([module.container_app.json_map, module.container_nginx.json_map])))
}

module "fargate_resources" {
  source = "../fargate-resources"

  cpu    = module.container_app.cpu + module.container_nginx.cpu
  memory = module.container_app.memory + module.container_nginx.memory
}

resource "aws_ecs_task_definition" "this" {
  family                = var.override_ecs_task_definition_family != null ? var.override_ecs_task_definition_family : local.full_name
  container_definitions = local.container_definitions

  cpu                      = module.fargate_resources.cpu
  memory                   = module.fargate_resources.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = local.tags

  execution_role_arn = var.app_generic_config.iam_role_task_execution_role_arn
  task_role_arn      = var.task_role_arn

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [var.ephemeral_storage_size] : []
    content {
      size_in_gib = ephemeral_storage.value
    }
  }

  dynamic "volume" {
    for_each = var.volumes
    content {
      configure_at_launch = false
      name                = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", "/")
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", "ENABLED")
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", 2999)

          dynamic "authorization_config" {
            for_each = contains(keys(efs_volume_configuration.value), "authorization_config") && efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              iam = authorization_config.value.iam
            }
          }
        }
      }
    }
  }
}

// https://www.terraform.io/docs/providers/aws/d/ecs_task_definition.html
// Simply specify the family to find the latest ACTIVE revision in that family.
data "aws_ecs_task_definition" "this" {
  // This data source is tricky. It when simple task_definition = family is set, new services fail to be created (during plan)
  // as there is no task definition available yet.
  // Setting depends_on forces read to be executed during apply phase instead of refresh phase forcing constant applies
  // Because family is one of input fields its passed to output without any action need on aws site.
  // I've added reference to arn in order to force data execution to time after resource creation. This allows
  // creation of new resources and doesn't require apply after every change.
  task_definition = aws_ecs_task_definition.this.arn != null ? aws_ecs_task_definition.this.family : null
}

locals {
  desired_count = var.desired_count != null ? var.desired_count : var.app_generic_config.environment == "prod" ? 2 : 1
}

resource "aws_ecs_service" "this" {
  name          = var.override_ecs_service_name != null ? var.override_ecs_service_name : local.full_name
  cluster       = var.app_generic_config.ecs_cluster_config.id
  desired_count = local.desired_count

  enable_execute_command = var.ecs_exec_enabled
  // iam_role = ...
  // This parameter is required if you are using a load balancer with your service,
  // but only if your task definition does not use the awsvpc network mode.
  // If using awsvpc network mode, do not specify this role. 

  task_definition = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"

  // Specifying both a launch type and capacity provider strategy is not supported. Remove one and try again.
  // launch_type = "FARGATE" 
  tags = local.tags

  // https://www.terraform.io/docs/providers/aws/r/ecs_service.html#network_configuration
  network_configuration {
    subnets          = var.assign_public_ip ? var.app_generic_config.public_subnet_ids : var.app_generic_config.private_subnet_ids
    security_groups  = [var.app_generic_config.security_group_id]
    assign_public_ip = var.assign_public_ip
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.key
      weight            = capacity_provider_strategy.value
    }
  }

  dynamic "load_balancer" {
    for_each = local.alb_enabled ? [true] : []
    content {
      container_name   = var.http_enabled ? module.container_app.name : module.container_nginx.name
      container_port   = 80
      target_group_arn = aws_lb_target_group.this[0].arn
    }
  }

  dynamic "load_balancer" {
    for_each = var.custom_ports
    content {
      container_name   = module.container_app.name
      container_port   = load_balancer.key
      target_group_arn = load_balancer.value
    }
  }

  wait_for_steady_state = true
  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }
}
