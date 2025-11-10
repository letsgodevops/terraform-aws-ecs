variable "warning_sns_topic_arns" {
  description = "List of SNS topic ARNs which we'll use to send warning messages"
  type        = list(string)
  default     = []
  # validation {
  #   condition     = length(var.warning_sns_topic_arns) >= 1
  #   error_message = "The critical_sns_topic_arns needs to contain at least 1 element."
  # }
}

variable "critical_sns_topic_arns" {
  description = "List of SNS topic ARNs which we'll use to send critical messages"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "AWS Tags"
  default     = {}
}

variable "name" {
  description = "Name for the alarm"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN for target group, e.g. aws_lb_target_group.this.arn_suffix"
  type        = string
}

variable "lb_arn_suffix" {
  type        = string
  description = "ARN for load balancer, this converts to LoadBalancer name used as dimension in CloudWatch alarm"
}

variable "enabled" {
  description = "Variable to enable or disable alarms"
  default     = true
  type        = bool
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  default     = 60
  type        = number
}

variable "target_response_time" {
  description = "The avarage response time in seconds over which the alarm is applied."
  type        = map(string)
  default = {
    "warning"  = 1
    "critical" = 2
  }
}

variable "httpcode_target_5xx_count" {
  description = "The threashold for 5xx errors."
  type        = map(string)
  default = {
    "warning"  = 1
    "critical" = 10
  }
}


variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 3
  type        = number
}
