locals {
  container_definition = {
    name              = var.name
    image             = var.image
    essential         = var.essential
    entryPoint        = var.entrypoint
    command           = var.command
    portMappings      = var.port_mappings
    healthCheck       = var.healthcheck
    memory            = var.memory
    memoryReservation = var.memory_reservation
    cpu               = var.cpu
    environment       = var.environment_variables
    secrets           = var.secrets
    logConfiguration  = var.log_configuration

    // set default to avoid changes on plan, e.g.: delete `- mountPoints : [ ]`
    mountPoints = var.mount_points
    volumesFrom = []
  }

  json_map = jsonencode(local.container_definition)
}