locals {
  scheduler_dlq_pattern = "${aws_ecs_service.this.name}-scheduler-%s-dlq"
}

resource "aws_scheduler_schedule_group" "this" {
  name = local.service_name
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com", "pipes.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name = "${aws_ecs_service.this.name}-scheduler"

  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

resource "aws_iam_role_policy" "scheduler_policy" {
  role = aws_iam_role.scheduler.id

  policy = data.aws_iam_policy_document.scheduler_policy.json
}

data "aws_iam_policy_document" "scheduler_policy" {
  statement {
    effect  = "Allow"
    actions = ["ecs:RunTask"]


    condition {
      test     = "ArnLike"
      variable = "ecs:cluster"
      values   = [var.app_generic_config.ecs_cluster_config.arn]
    }

    resources = [
      aws_ecs_task_definition.this.arn_without_revision,
      "${aws_ecs_task_definition.this.arn_without_revision}:*",
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }

    resources = [
      "*",
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
    resources = [
      "*",
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:${format(local.scheduler_dlq_pattern, "*")}"
    ]
  }
}
