variable "name" {
  type        = string
  description = "The name of the scheduler schedule"
}

variable "enabled" {
  type        = bool
  description = "Whether the schedule is enabled"
  default     = true
}

variable "schedule_expression" {
  type        = string
  description = "The scheduling expression. For example, 'rate(5 minutes)' or 'cron(0 12 * * ? *)'"
}

variable "command" {
  type        = list(string)
  description = "The command to run in the container"
}

variable "public_network" {
  default     = false
  type        = bool
  description = "Whether to use public or private subnets for the scheduler task"
}
variable "service_config" {
  type = object({
    cluster_arn           = string
    task_definition_arn   = string
    container_name        = string
    private_subnet_ids    = list(string)
    public_subnet_ids     = list(string)
    security_group_id     = string
    schedule_group        = string
    scheduler_role_arn    = string
    scheduler_dlq_pattern = string
  })
  description = "Configuration for the ECS service to run the scheduled task. Provided as output from the ECS service module"
}
