resource "aws_appautoscaling_target" "as_target" {
  count = 1

  resource_id        = "service/${var.app_generic_config.ecs_cluster_config.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = local.desired_count
  max_capacity       = var.as_max_capacity
  service_namespace  = "ecs"
}

# Target tracking options:
# * ECSServiceAverageCPUUtilization
# * ECSServiceAverageMemoryUtilization
# * ALBRequestCountPerTarget
resource "aws_appautoscaling_policy" "as_lb" {
  count = local.alb_count > 0 ? 1 : 0

  name               = "ALB"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.as_target.0.resource_id
  scalable_dimension = aws_appautoscaling_target.as_target.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.as_target.0.service_namespace

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 60
    scale_out_cooldown = 120
    target_value       = var.as_alb_rq_target

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${local.alb_lb_name}/${aws_lb_target_group.this.0.arn_suffix}"
    }
  }
}

resource "aws_appautoscaling_policy" "as_cpu" {
  count = 1

  name               = "CPU"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.as_target.0.resource_id
  scalable_dimension = aws_appautoscaling_target.as_target.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.as_target.0.service_namespace

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = var.as_cpu_scale_in_cooldown
    scale_out_cooldown = 120
    target_value       = var.as_cpu_target

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "as_memory" {
  count = 1

  name               = "Memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.as_target.0.resource_id
  scalable_dimension = aws_appautoscaling_target.as_target.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.as_target.0.service_namespace

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 120
    target_value       = var.as_memory_target

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

// autlscaling based on sqs
resource "aws_appautoscaling_policy" "sqs_scale_up" {
  count              = var.as_sqs_queue_name != null ? 1 : 0
  policy_type        = "StepScaling"
  name               = "sqs_scale_up"
  resource_id        = aws_appautoscaling_target.as_target.0.resource_id
  scalable_dimension = aws_appautoscaling_target.as_target.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.as_target.0.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    metric_aggregation_type = "Average"
    cooldown                = 30

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 25
      scaling_adjustment          = 1
    }
    step_adjustment {
      metric_interval_lower_bound = 25
      metric_interval_upper_bound = 200
      scaling_adjustment          = 5
    }
    step_adjustment {
      metric_interval_lower_bound = 200
      scaling_adjustment          = 20
    }
  }
}

resource "aws_appautoscaling_policy" "sqs_scale_down" {
  count              = var.as_sqs_queue_name != null ? 1 : 0
  policy_type        = "StepScaling"
  name               = "sqs_scale_down"
  resource_id        = aws_appautoscaling_target.as_target.0.resource_id
  scalable_dimension = aws_appautoscaling_target.as_target.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.as_target.0.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    metric_aggregation_type = "Average"
    cooldown                = var.as_sqs_scale_down_cooldown

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_scale_up" {
  count                     = var.as_sqs_queue_name != null ? 1 : 0
  alarm_name                = format("sqs_scale_up_%s_%s", aws_ecs_service.this.name, var.role)
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "ApproximateNumberOfMessagesVisible"
  namespace                 = "AWS/SQS"
  period                    = "60"
  threshold                 = "1"
  statistic                 = "Sum"
  alarm_description         = "SQS scale up alarm for ${aws_ecs_service.this.name}"
  insufficient_data_actions = []
  alarm_actions             = [aws_appautoscaling_policy.sqs_scale_up.0.arn]

  dimensions = {
    QueueName = var.as_sqs_queue_name
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_scale_down" {
  count               = var.as_sqs_queue_name != null ? 1 : 0
  alarm_name          = format("sqs_scale_down_%s_%s", aws_ecs_service.this.name, var.role)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  threshold           = "1"
  statistic           = "Sum"
  alarm_description   = "SQS scale up alarm for ${aws_ecs_service.this.name}"
  alarm_actions       = [aws_appautoscaling_policy.sqs_scale_down.0.arn]


  dimensions = {
    QueueName = var.as_sqs_queue_name
  }
}
