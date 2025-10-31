resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count = var.create

  alarm_name          = format("ecs_cpu_%s", var.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.period // Duration in seconds to evaluate for the alarm
  statistic           = "Average"
  unit                = "Percent"
  threshold           = var.cpu_utilization_threshold

  treat_missing_data = "notBreaching"

  alarm_description = format("CPUUtilization > %d for %d datapoints within %d minute for %s",
  var.cpu_utilization_threshold, var.evaluation_periods, var.period / 60, var.name)
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  insufficient_data_actions = []

  dimensions = {
    "ServiceName" = var.service_name
    "ClusterName" = var.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  count = var.create

  alarm_name          = format("ecs_memory_%s", var.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.period // Duration in seconds to evaluate for the alarm
  statistic           = "Average"
  unit                = "Percent"
  threshold           = var.memory_utilization_threshold

  treat_missing_data = "notBreaching"

  alarm_description = format("MemoryUtilization > %d for %d datapoints within %d minute for %s",
  var.cpu_utilization_threshold, var.evaluation_periods, var.period / 60, var.name)
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  insufficient_data_actions = []

  dimensions = {
    "ServiceName" = var.service_name
    "ClusterName" = var.cluster_name
  }

  tags = var.tags
}
