variable "source_queue" {

}

resource "aws_iam_role_policy" "source" {
  name = "pipe-${var.name}"
  role = "stage-kupuje-v2-cron-scheduler"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
        ],
        Resource = [
          var.source_queue,
        ]
      },
    ]
  })
}

resource "aws_pipes_pipe" "this" {
  depends_on = [aws_iam_role_policy.source]

  name = var.name

  role_arn = var.service_config.scheduler_role_arn
  source   = var.source_queue
  target   = var.service_config.cluster_arn

  target_parameters {
    ecs_task_parameters {
      task_definition_arn = var.service_config.task_definition_arn
      launch_type         = "FARGATE"

      network_configuration {
        aws_vpc_configuration {
          subnets = var.public_network ? var.service_config.public_subnet_ids : var.service_config.private_subnet_ids

          security_groups = [
            var.service_config.security_group_id
          ]
          assign_public_ip = var.public_network ? "ENABLED" : "DISABLED"
        }
      }

      # log_configuration {} // TODO

      enable_execute_command  = true
      enable_ecs_managed_tags = true

      task_count = 1

      overrides {
        container_override {
          name    = var.service_config.container_name
          command = ["echo $${AWS_PAYLOAD}"]

          environment {
            name  = "AWS_PAYLOAD"
            value = "$.body"
          }
          cpu                = data.aws_ecs_task_definition.this.cpu
          memory             = data.aws_ecs_task_definition.this.memory
          memory_reservation = data.aws_ecs_task_definition.this.memory
        }
      }
    }

  }
}

data "aws_ecs_task_definition" "this" {
  task_definition = var.service_config.task_definition_arn
}
resource "aws_sqs_queue" "scheduler_dlq" {
  name = format(var.service_config.scheduler_dlq_pattern, var.name)
}
