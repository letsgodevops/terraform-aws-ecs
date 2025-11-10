# ecs-container

Terraform module to generate well-formed JSON documents that are passed to the aws_ecs_task_definition Terraform resource as [container definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions).                                                                                                |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_command"></a> [command](#input\_command) | The command that is passed to the container | `list(string)` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container\_cpu of all containers in a task will need to be lower than the task-level cpu value | `number` | `256` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Determine if any output should be returned by module (if failse - json and resource info will be nulled) | `bool` | `true` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The entry point that is passed to the container | `list(string)` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | The environment variables to pass to the container. This is a list of maps | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_essential"></a> [essential](#input\_essential) | Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `true` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | A map containing command (string), timeout, interval (duration in seconds), retries (1-10, number of times to retry before marking container unhealthy), and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries) | <pre>object({<br/>    command     = list(string)<br/>    retries     = number<br/>    timeout     = number<br/>    interval    = number<br/>    startPeriod = number<br/>  })</pre> | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | The image used to start the container. Images in the Docker Hub registry available by default | `string` | n/a | yes |
| <a name="input_log_configuration"></a> [log\_configuration](#input\_log\_configuration) | Log configuration options to send to a custom log driver for the container. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html | <pre>object({<br/>    logDriver = string<br/>    options   = map(string)<br/>  })</pre> | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the memory, the container is killed. This field is optional for Fargate launch type and the total amount of memory of all containers in a task will need to be lower than the task memory value | `number` | `512` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container\_memory hard limit | `number` | `128` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | A list of mount points for the ECS container. Each mount point should specify the source volume name and the container path where it will be mounted. | <pre>list(object({<br/>    sourceVolume  = string<br/>    containerPath = string<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, \_ allowed) | `string` | n/a | yes |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br/>    containerPort = number<br/>    hostPort      = number<br/>    protocol      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The secrets to pass to the container. This is a list of maps | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cpu"></a> [cpu](#output\_cpu) | The number of cpu units to reserve for the container. |
| <a name="output_json_map"></a> [json\_map](#output\_json\_map) | JSON encoded container definitions for use with other terraform resources such as aws\_ecs\_task\_definition |
| <a name="output_memory"></a> [memory](#output\_memory) | The amount of memory (in MiB) to allow the container to use. |
| <a name="output_name"></a> [name](#output\_name) | Container name |
<!-- END_TF_DOCS -->