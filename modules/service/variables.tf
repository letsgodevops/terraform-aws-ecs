variable "role" {
  type        = string
  description = "The role of the container (e.g. 'app', 'nginx')"
}

variable "container_name" {
  type        = string
  description = "The name of the container"
}

variable "entrypoint" {
  type        = list(string)
  description = "The entry point that is passed to the container"
  default     = null
}

// container variables
variable "environment_variables" {
  description = "The environment variables to pass to all application containers"
  type = list(object({
    name  = string
    value = string
  }))
  default = null
}

variable "secret_variables" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "The secrets to pass to the container. This is a list of maps"
  default     = null
}

variable "mount_points" {
  type = list(object({
    sourceVolume  = string
    containerPath = string
    readOnly      = optional(bool, false)
  }))
  description = "The mount points for the container"
  default     = []
}
variable "volumes" {
  type = list(object({
    name                = string
    configure_at_launch = optional(bool, false)
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string, "/")
      transit_encryption      = optional(string, "ENABLED")
      transit_encryption_port = optional(number, 0)
      authorization_config = optional(object({
        iam = string
      }))
    }))
    host_path = optional(string)
  }))
  description = "The volumes to attach to the container"
  default     = []
}

variable "internal_lb" {
  type        = bool
  description = "Enables Nginx container and Internal ALB target group"
  default     = false
}

variable "external_lb" {
  type        = bool
  description = "Enables Nginx container and Public ALB target group"
  default     = false
}

variable "ecs_exec_enabled" {
  type        = bool
  description = "Enable ECS Execute Command for the service"
  default     = false
}

variable "domain" {
  type        = string
  description = "Domain name - required if internal_lb or external_lb enabled"
  default     = ""
}

variable "app_generic_config" {
  description = "Configuration passed from app-generic module"
}

variable "task_role_arn" {
  type        = string
  description = "Role used by (running) task"
  default     = ""
}

variable "ssh_enabled" {
  type        = bool
  description = "Open SSH Port (through Network Load Balancer) to main application container"
  default     = false
}

variable "custom_ports" {
  type        = map(string)
  description = "Map of custom ports with corresponding ALB Listener"
  default     = {}
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ENI. Required True for public subnets"
  default     = true
}

variable "custom_imagedefinitions" {
  type        = string
  default     = null
  description = "Hack! Ability to set custom imagedefinition for migration"
}

// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
variable "memory" {
  type        = number
  description = "The amount of memory (in MiB) to allow the service to use."
  default     = null
}

variable "cpu" {
  type        = number
  description = "The number of cpu units to reserve for the service."
  default     = null
}

# Hack! Workaround for default values which for smallest instances depend on enabled alb
locals {
  default_memory = local.alb_enabled ? 1024 : 512
  memory         = var.memory == null ? local.default_memory : var.memory

  default_cpu = local.alb_enabled ? 512 : 256
  cpu         = var.cpu == null ? local.default_cpu : var.cpu
}

variable "as_max_capacity" {
  type        = number
  description = "AutoScaler: Maximal numebr of service instances"
  default     = 10
}

variable "as_cpu_target" {
  type        = number
  description = "AutoScaler: Target CPU value for service autoscaling"
  default     = 60
}

variable "as_memory_target" {
  type        = number
  description = "AutoScaler: Target Memory value for service autoscaling"
  default     = 60
}

variable "as_cpu_scale_in_cooldown" {
  type        = number
  description = "AutoScaler: Cooldown period in seconds after scale-in activity"
  default     = 300
}

variable "as_alb_rq_target" {
  type        = number
  description = "AutoScaler: Target Application Load Balancer RQs/target value for service autoscaling"
  default     = 20
}

variable "desired_count" {
  type        = number
  description = "(Optional) The number of instances of the task definition to place and keep running. Defaults to 1 for non-prod and 2 for prod."
  // valid number is chosen later based on the env name
  default = null
}

variable "warning_notifications" {
  type = list(string)
}

variable "critical_notifications" {
  type = list(string)
}

variable "alb_paths" {
  type        = list(string)
  default     = null
  description = "List of custom path for alb target group"
}

variable "skip_domain_creation" {
  type        = bool
  default     = false
  description = "Hack! Skip domain creation if it was already created in different service setup. Required if you want to have different routing per path"
}

variable "override_tagret_group_name" {
  default     = null
  type        = string
  description = "Hack! By default we have one TG per application setup. This allows to explitly overwrite app part in TG name."
}

// scaling workers based on SQS
variable "as_sqs_queue_name" {
  default     = null
  type        = string
  description = "The name of the SQS queue to use for scaling"
}

variable "as_sqs_scale_down_cooldown" {
  default     = 60
  type        = number
  description = "AutoScaler: Cooldown period in seconds after scale-out activity"
}

variable "as_sqs_step_adjustment" {
  type = list(object({ metric_interval_lower_bound = string, metric_interval_upper_bound = string, scaling_adjustment = string }))
  default = [
    {
      metric_interval_lower_bound = 1
      metric_interval_upper_bound = 500
      scaling_adjustment          = 1
    },
    {
      metric_interval_lower_bound = 500
      metric_interval_upper_bound = 1000
      scaling_adjustment          = 2
    },
    {
      metric_interval_lower_bound = 1000
      metric_interval_upper_bound = 2000
      scaling_adjustment          = 3
    }
  ]
}

variable "alarm_target_response_time" {
  description = "The avarage response time in seconds over which the alarm is applied."
  type        = map(string)
  default = {
    "warning"  = 1
    "critical" = 2
  }
}

variable "create_ecs_alarms" {
  type        = bool
  description = "Set to `false` to not create alarms"
  default     = true
}

variable "http_enabled" {
  type        = bool
  description = "Enable HTTP port for the service"
  default     = false
}

variable "health_check_cmd" {
  type        = string
  description = "Command to check health of the container"
  default     = null
}

variable "capacity_provider_strategy" {
  description = "Map of capacity providers and weights. Only valid keys: FARGATE_SPOT, FARGATE. Weights must sum to 100."
  type        = map(number)
  default = {
    FARGATE_SPOT = 95
    FARGATE      = 5
  }

  validation {
    condition     = alltrue([for key in keys(var.capacity_provider_strategy) : key == "FARGATE_SPOT" || key == "FARGATE"])
    error_message = "Only FARGATE_SPOT and FARGATE are valid capacity provider keys."
  }
}

variable "ephemeral_storage_size" {
  type        = number
  description = "The size, in GiB, of the ephemeral storage to set for the task. The minimum supported value is 21 GiB."
  default     = null
}

variable "override_ecs_service_name" {
  type        = string
  description = "Hack! Overwrite the name of the ECS service - for importing existing services"
  default     = null
}

variable "override_ecs_task_definition_family" {
  type        = string
  description = "Hack! Overwrite the family of the ECS task definition - for importing existing task definitions"
  default     = null
}

variable "add_suffix_to_name" {
  type        = string
  description = "Hack! Suffix is added to most of the resources created by this module. Used to avoid conflicts."
  default     = null
}

variable "memory_reservation" {
  type        = number
  default     = 256
  description = "Memory reservation for the container"
}
