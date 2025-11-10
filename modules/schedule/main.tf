resource "aws_scheduler_schedule" "this" {
  name       = var.name
  group_name = var.service_config.schedule_group
  state      = var.enabled ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_expression


  target {
    arn      = var.service_config.cluster_arn
    role_arn = var.service_config.scheduler_role_arn


    input = jsonencode({
      containerOverrides = [
        {
          name    = var.service_config.container_name
          command = var.command
          #   environment = []
        }
      ]
    })

    ecs_parameters {
      task_definition_arn = var.service_config.task_definition_arn
      launch_type         = "FARGATE"

      network_configuration {
        subnets = var.public_network ? var.service_config.public_subnet_ids : var.service_config.private_subnet_ids

        security_groups = [
          var.service_config.security_group_id
        ]
        assign_public_ip = var.public_network
      }

      enable_execute_command  = true
      enable_ecs_managed_tags = true

      task_count = 1
    }

    dead_letter_config {
      arn = aws_sqs_queue.scheduler_dlq.arn
    }

    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}

resource "aws_sqs_queue" "scheduler_dlq" {
  name = format(var.service_config.scheduler_dlq_pattern, var.name)
}
