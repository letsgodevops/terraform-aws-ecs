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
  default = 80
}

variable "memory_utilization_threshold" {
  default = 80
}

variable "create" {
  description = "Variable to enable or disable alarms"
  default     = 1
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 3
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  default     = 60
}
