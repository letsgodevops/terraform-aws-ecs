output "alarm_arns" {
  description = "The ARNs of the created CloudWatch alarms"
  value       = concat(aws_cloudwatch_metric_alarm.httpcode_target_5xx_count.*.arn)
}
