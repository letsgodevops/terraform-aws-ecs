# ECS service

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb_alarms"></a> [alb\_alarms](#module\_alb\_alarms) | ../cloudwatch-alarms/alb | n/a |
| <a name="module_container_app"></a> [container\_app](#module\_container\_app) | ../container | n/a |
| <a name="module_container_nginx"></a> [container\_nginx](#module\_container\_nginx) | ../container | n/a |
| <a name="module_dashboard"></a> [dashboard](#module\_dashboard) | github.com/letsgodevops/terraform-aws-cloudwatch//modules/dashboards/ecs | v0.0.4 |
| <a name="module_ecs_alarms"></a> [ecs\_alarms](#module\_ecs\_alarms) | ../cloudwatch-alarms/ecs | n/a |
| <a name="module_fargate_resources"></a> [fargate\_resources](#module\_fargate\_resources) | ../fargate-resources | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.as_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.as_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.as_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.sqs_scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.sqs_scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.as_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.sqs_scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.sqs_scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.scheduler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lb_listener_rule.domain_routing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_scheduler_schedule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule_group) | resource |
| [aws_security_group_rule.allow_http_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [cloudflare_record.exteranl](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.scheduler_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scheduler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_suffix_to_name"></a> [add\_suffix\_to\_name](#input\_add\_suffix\_to\_name) | Hack! Suffix is added to most of the resources created by this module. Used to avoid conflicts. | `string` | `null` | no |
| <a name="input_alarm_target_response_time"></a> [alarm\_target\_response\_time](#input\_alarm\_target\_response\_time) | The avarage response time in seconds over which the alarm is applied. | `map(string)` | <pre>{<br/>  "critical": 2,<br/>  "warning": 1<br/>}</pre> | no |
| <a name="input_alb_paths"></a> [alb\_paths](#input\_alb\_paths) | List of custom path for alb target group | `list(string)` | `null` | no |
| <a name="input_app_generic_config"></a> [app\_generic\_config](#input\_app\_generic\_config) | Configuration passed from app-generic module | `any` | n/a | yes |
| <a name="input_as_alb_rq_target"></a> [as\_alb\_rq\_target](#input\_as\_alb\_rq\_target) | AutoScaler: Target Application Load Balancer RQs/target value for service autoscaling | `number` | `20` | no |
| <a name="input_as_cpu_scale_in_cooldown"></a> [as\_cpu\_scale\_in\_cooldown](#input\_as\_cpu\_scale\_in\_cooldown) | AutoScaler: Cooldown period in seconds after scale-in activity | `number` | `300` | no |
| <a name="input_as_cpu_target"></a> [as\_cpu\_target](#input\_as\_cpu\_target) | AutoScaler: Target CPU value for service autoscaling | `number` | `60` | no |
| <a name="input_as_max_capacity"></a> [as\_max\_capacity](#input\_as\_max\_capacity) | AutoScaler: Maximal numebr of service instances | `number` | `10` | no |
| <a name="input_as_memory_target"></a> [as\_memory\_target](#input\_as\_memory\_target) | AutoScaler: Target Memory value for service autoscaling | `number` | `60` | no |
| <a name="input_as_sqs_queue_name"></a> [as\_sqs\_queue\_name](#input\_as\_sqs\_queue\_name) | The name of the SQS queue to use for scaling | `string` | `null` | no |
| <a name="input_as_sqs_scale_down_cooldown"></a> [as\_sqs\_scale\_down\_cooldown](#input\_as\_sqs\_scale\_down\_cooldown) | AutoScaler: Cooldown period in seconds after scale-out activity | `number` | `60` | no |
| <a name="input_as_sqs_step_adjustment"></a> [as\_sqs\_step\_adjustment](#input\_as\_sqs\_step\_adjustment) | n/a | `list(object({ metric_interval_lower_bound = string, metric_interval_upper_bound = string, scaling_adjustment = string }))` | <pre>[<br/>  {<br/>    "metric_interval_lower_bound": 1,<br/>    "metric_interval_upper_bound": 500,<br/>    "scaling_adjustment": 1<br/>  },<br/>  {<br/>    "metric_interval_lower_bound": 500,<br/>    "metric_interval_upper_bound": 1000,<br/>    "scaling_adjustment": 2<br/>  },<br/>  {<br/>    "metric_interval_lower_bound": 1000,<br/>    "metric_interval_upper_bound": 2000,<br/>    "scaling_adjustment": 3<br/>  }<br/>]</pre> | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI. Required True for public subnets | `bool` | `true` | no |
| <a name="input_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#input\_capacity\_provider\_strategy) | Map of capacity providers and weights. Only valid keys: FARGATE\_SPOT, FARGATE. Weights must sum to 100. | `map(number)` | <pre>{<br/>  "FARGATE": 5,<br/>  "FARGATE_SPOT": 95<br/>}</pre> | no |
| <a name="input_command"></a> [command](#input\_command) | The command that is passed to the container | `list(string)` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the container | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units to reserve for the service. | `number` | `null` | no |
| <a name="input_create_ecs_alarms"></a> [create\_ecs\_alarms](#input\_create\_ecs\_alarms) | Set to `false` to not create alarms | `bool` | `true` | no |
| <a name="input_critical_notifications"></a> [critical\_notifications](#input\_critical\_notifications) | n/a | `list(string)` | n/a | yes |
| <a name="input_custom_imagedefinitions"></a> [custom\_imagedefinitions](#input\_custom\_imagedefinitions) | Hack! Ability to set custom imagedefinition for migration | `string` | `null` | no |
| <a name="input_custom_ports"></a> [custom\_ports](#input\_custom\_ports) | Map of custom ports with corresponding ALB Listener | `map(string)` | `{}` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | (Optional) The number of instances of the task definition to place and keep running. Defaults to 1 for non-prod and 2 for prod. | `number` | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain name - required if internal\_lb or external\_lb enabled | `string` | `""` | no |
| <a name="input_ecs_exec_enabled"></a> [ecs\_exec\_enabled](#input\_ecs\_exec\_enabled) | Enable ECS Execute Command for the service | `bool` | `false` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The entry point that is passed to the container | `list(string)` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | The environment variables to pass to all application containers | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_ephemeral_storage_size"></a> [ephemeral\_storage\_size](#input\_ephemeral\_storage\_size) | The size, in GiB, of the ephemeral storage to set for the task. The minimum supported value is 21 GiB. | `number` | `null` | no |
| <a name="input_external_lb"></a> [external\_lb](#input\_external\_lb) | Enables Nginx container and Public ALB target group | `bool` | `false` | no |
| <a name="input_health_check_cmd"></a> [health\_check\_cmd](#input\_health\_check\_cmd) | Command to check health of the container | `string` | `null` | no |
| <a name="input_http_enabled"></a> [http\_enabled](#input\_http\_enabled) | Enable HTTP port for the service | `bool` | `false` | no |
| <a name="input_internal_lb"></a> [internal\_lb](#input\_internal\_lb) | Enables Nginx container and Internal ALB target group | `bool` | `false` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory (in MiB) to allow the service to use. | `number` | `null` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | Memory reservation for the container | `number` | `256` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | The mount points for the container | <pre>list(object({<br/>    sourceVolume  = string<br/>    containerPath = string<br/>    readOnly      = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_override_ecs_service_name"></a> [override\_ecs\_service\_name](#input\_override\_ecs\_service\_name) | Hack! Overwrite the name of the ECS service - for importing existing services | `string` | `null` | no |
| <a name="input_override_ecs_task_definition_family"></a> [override\_ecs\_task\_definition\_family](#input\_override\_ecs\_task\_definition\_family) | Hack! Overwrite the family of the ECS task definition - for importing existing task definitions | `string` | `null` | no |
| <a name="input_override_tagret_group_name"></a> [override\_tagret\_group\_name](#input\_override\_tagret\_group\_name) | Hack! By default we have one TG per application setup. This allows to explitly overwrite app part in TG name. | `string` | `null` | no |
| <a name="input_role"></a> [role](#input\_role) | The role of the container (e.g. 'app', 'nginx') | `string` | n/a | yes |
| <a name="input_secret_variables"></a> [secret\_variables](#input\_secret\_variables) | The secrets to pass to the container. This is a list of maps | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `null` | no |
| <a name="input_skip_domain_creation"></a> [skip\_domain\_creation](#input\_skip\_domain\_creation) | Hack! Skip domain creation if it was already created in different service setup. Required if you want to have different routing per path | `bool` | `false` | no |
| <a name="input_ssh_enabled"></a> [ssh\_enabled](#input\_ssh\_enabled) | Open SSH Port (through Network Load Balancer) to main application container | `bool` | `false` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | Role used by (running) task | `string` | `""` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | The volumes to attach to the container | <pre>list(object({<br/>    name                = string<br/>    configure_at_launch = optional(bool, false)<br/>    efs_volume_configuration = optional(object({<br/>      file_system_id          = string<br/>      root_directory          = optional(string, "/")<br/>      transit_encryption      = optional(string, "ENABLED")<br/>      transit_encryption_port = optional(number, 0)<br/>      authorization_config = optional(object({<br/>        iam = string<br/>      }))<br/>    }))<br/>    host_path = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_warning_notifications"></a> [warning\_notifications](#input\_warning\_notifications) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_deployment_configuration"></a> [ecs\_deployment\_configuration](#output\_ecs\_deployment\_configuration) | The ECS deployment configuration used by CodePipeline |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | The name of the ECS service |
| <a name="output_external_url"></a> [external\_url](#output\_external\_url) | The external URL of the service |
| <a name="output_internal_fqdn"></a> [internal\_fqdn](#output\_internal\_fqdn) | The FQDN of internal route53 record |
| <a name="output_monitoring"></a> [monitoring](#output\_monitoring) | CloudWatch dashboard and alarms for the ECS service |
| <a name="output_schedule_config"></a> [schedule\_config](#output\_schedule\_config) | n/a |
<!-- END_TF_DOCS -->