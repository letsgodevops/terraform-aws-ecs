# EventBridge based schedule

Module is creating cron-like configuration to run commands inside the ECS Service.
Running tasks can be found under ECS -> Cluster -> Service -> Tasks (they are marked as executed by scheduler)


## Fun-facts about the configuration

### Errors

In case Service / EventBridge / Role get misconfigured there is no easy way to get to logs. Failed tasks (due to misconfiguration) are not reported in the metrics. 
The only way to get the execution error rol is through Dead Letter Queue (which is by default created for the schedule)

### Services vs Tasks

It's not possible to execute standalone task on Fargate. In order to get cron-like experience we need to create service and either:
* Keep it shut (desired count = 0) and just execute tasks
* Execute tasks in parallel to the service with overwritten command


### Entrypoint vs Command

Scheduler allows for JSON Overwrites for the tasks in ECS, unfortunately the configuration is rather limited, therefore we can only overwrite the command attribute (entrypoint need to be split or moved)


## Missing features
* Create alerts on execution metrics (especially failed tasks)
* Monitoring for DLQ (alert when >1)


# Example

```
module "schedule" {
  source = "github.com/letsgodevops/terraform-aws-ecs//modules/service?ref=XYZ"

  name                = "cron"
  schedule_expression = "rate(1 minutes)"
  public_network      = true
  command             = ["echo 'Hello from scheduled task'"]

  service_config = module.ecs_main_cron.schedule_config
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_scheduler_schedule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_sqs_queue.scheduler_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_command"></a> [command](#input\_command) | The command to run in the container | `list(string)` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the schedule is enabled | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the scheduler schedule | `string` | n/a | yes |
| <a name="input_public_network"></a> [public\_network](#input\_public\_network) | Whether to use public or private subnets for the scheduler task | `bool` | `false` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | The scheduling expression. For example, 'rate(5 minutes)' or 'cron(0 12 * * ? *)' | `string` | n/a | yes |
| <a name="input_service_config"></a> [service\_config](#input\_service\_config) | Configuration for the ECS service to run the scheduled task. Provided as output from the ECS service module | <pre>object({<br/>    cluster_arn           = string<br/>    task_definition_arn   = string<br/>    container_name        = string<br/>    private_subnet_ids    = list(string)<br/>    public_subnet_ids     = list(string)<br/>    security_group_id     = string<br/>    schedule_group        = string<br/>    scheduler_role_arn    = string<br/>    scheduler_dlq_pattern = string<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->