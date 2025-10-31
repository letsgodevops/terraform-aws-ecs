output "alarm_arns" {
  value = concat(aws_cloudwatch_metric_alarm.httpcode_target_5xx_count.*.arn)
}
