variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "ok_actions" {
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
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

variable "cpu_utilization_threshold" {
  default     = 80
  type        = number
  description = "The threshold for CPU utilization alarm to go off"
}

variable "memory_utilization_threshold" {
  default     = 80
  type        = number
  description = "The threshold for Memory utilization alarm to go off"
}

variable "create" {
  description = "Variable to enable or disable alarms"
  default     = 1
  type        = number

  validation {
    condition     = var.create == 0 || var.create == 1
    error_message = "The variable 'create' must be either 0 (disable) or 1 (enable)."
  }
}

variable "cluster_name" {
  type        = string
  description = "ECS Cluster name where the service is deployed, used as dimension in CloudWatch alarm"
}

variable "service_name" {
  type        = string
  description = "ECS Service name, used as dimension in CloudWatch alarm"
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 3
  type        = number
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  default     = 60
  type        = number
}
