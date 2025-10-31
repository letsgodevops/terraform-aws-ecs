locals {
  # Allowed valued (from documentation)
  cpu_allowed = [256, 512, 1024, 2048, 4096]
  # Check if declared value fits in allowd CPU values, if not set big number
  # Example: reuired 300, output = [ 1000000, 512, 1024 ...]
  cpu_match = [for c in local.cpu_allowed : var.cpu <= c ? c : 100000]
  # Chose minimal value (as we set all not matching options to huge value)
  cpu_needed = min(local.cpu_match...)
}

output "cpu" {
  value = local.cpu_needed
}

locals {
  # allowed memory (for given CPU) form documentation
  mem_allowed = {
    256  = [512, 1024, 2048]
    512  = [1024, 2048, 3072, 4096]
    1024 = [2048, 3072, 4096, 5120, 6144, 7168, 8192]
    2048 = [4096, 5120, 6144, 7168, 8192, 9216, 10240, 11264, 12288, 13312, 14336, 15360, 16384]
    4096 = [8192, 9216, 10240, 11264, 12288, 13312, 14336, 15360, 16384] #up to 30GB
  }
  # we already have CPU requirements set, so chose allowed values
  cpu_mem_allowed = local.mem_allowed[local.cpu_needed]

  # Look at cpu_match description
  mem_match  = [for m in local.cpu_mem_allowed : var.memory <= m ? m : 100000]
  mem_needed = min(local.mem_match...)
}

output "memory" {
  value = local.mem_needed
}
