output "alarm_arns" {
  description = "The ARNs of the created CloudWatch alarms"
  value = concat(
    aws_cloudwatch_metric_alarm.cpu_utilization_high.*.arn,
    aws_cloudwatch_metric_alarm.memory_utilization_high.*.arn,
  )
}
