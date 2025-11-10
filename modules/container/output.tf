output "json_map" {
  description = "JSON encoded container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value       = var.enabled ? local.json_map : ""
}

output "name" {
  description = "Container name"
  value       = var.name
}

output "cpu" {
  description = "The number of cpu units to reserve for the container."
  value       = var.enabled ? var.cpu : 0
}

output "memory" {
  description = "The amount of memory (in MiB) to allow the container to use."
  value       = var.enabled ? var.memory : 0
}
