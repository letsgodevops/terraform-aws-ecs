locals {
  threshold_names = ["critical", "warning"]
}

resource "aws_cloudwatch_metric_alarm" "httpcode_target_5xx_count" {
  count = var.enabled == true ? 2 : 0

  alarm_name          = format("lb_%s_target_5xx_count_%s", var.name, local.threshold_names[count.index])
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1 // Number of periods to evaluate for the alarm
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.period // Duration in seconds to evaluate for the alarm
  statistic           = "Sum"
  threshold           = var.httpcode_target_5xx_count[local.threshold_names[count.index]]
  // https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarms-and-missing-data
  // notBreaching – Missing data points are treated as "good" and within the threshold - no traffic is ok at this case
  // Sets how alarms handle missing data points. Values supported: missing, ignore, breaching and notBreaching
  treat_missing_data = "notBreaching"

  alarm_description = "${upper(local.threshold_names[count.index])}: HTTPCode 5xx count for ${var.name} over last ${var.period / 60} minutes"

  alarm_actions             = local.threshold_names[count.index] == "critical" ? var.critical_sns_topic_arns : var.warning_sns_topic_arns
  ok_actions                = local.threshold_names[count.index] == "critical" ? var.critical_sns_topic_arns : var.warning_sns_topic_arns
  insufficient_data_actions = []

  dimensions = {
    "TargetGroup"  = var.target_group_arn_suffix
    "LoadBalancer" = var.lb_arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "target_response_time_average" {
  count = var.enabled == true ? 2 : 0

  alarm_name          = format("lb_%s_target_response_time_average_%s", var.name, local.threshold_names[count.index])
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.period
  statistic           = "Average"
  threshold           = var.target_response_time[local.threshold_names[count.index]]
  treat_missing_data  = "notBreaching"
  alarm_description   = "${upper(local.threshold_names[count.index])}: Average ${var.name} response time is above the ${var.target_response_time[local.threshold_names[count.index]]} sec for the last ${var.period / 60} minutes"

  alarm_actions             = local.threshold_names[count.index] == "critical" ? var.critical_sns_topic_arns : var.warning_sns_topic_arns
  ok_actions                = local.threshold_names[count.index] == "critical" ? var.critical_sns_topic_arns : var.warning_sns_topic_arns
  insufficient_data_actions = []

  dimensions = {
    "TargetGroup"  = var.target_group_arn_suffix
    "LoadBalancer" = var.lb_arn_suffix
  }
  tags = var.tags
}

// HTTPCode_ELB_503_Count - case for no backend available
resource "aws_cloudwatch_metric_alarm" "HTTPCode_ELB_503_Count" {
  count = var.enabled == true ? 2 : 0

  alarm_name          = format("lb_%s_503_count_%s", var.name, local.threshold_names[count.index])
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1 // Number of periods to evaluate for the alarm
  metric_name         = "HTTPCode_ELB_503_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.period // Duration in seconds to evaluate for the alarm
  statistic           = "Sum"
  threshold           = var.httpcode_target_5xx_count[local.threshold_names[count.index]]
  // https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarms-and-missing-data
  // notBreaching – Missing data points are treated as "good" and within the threshold - no traffic is ok at this case
  // Sets how alarms handle missing data points. Values supported: missing, ignore, breaching and notBreaching
  treat_missing_data = "notBreaching"

  alarm_description = "${upper(local.threshold_names[count.index])}: HTTPCode 503 count for ${var.name} over last ${var.period / 60} minutes"

  alarm_actions             = local.threshold_names[count.index] == "critical" ? var.critical_sns_topic_arns : var.warning_sns_topic_arns
  ok_actions                = local.threshold_names[count.index] == "critical" ? var.critical_sns_topic_arns : var.warning_sns_topic_arns
  insufficient_data_actions = []

  dimensions = {
    "TargetGroup"  = var.target_group_arn_suffix
    "LoadBalancer" = var.lb_arn_suffix
  }

  tags = var.tags
}
