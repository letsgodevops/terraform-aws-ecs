Creates default AWS CloudWatch alarm for ECS Service

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
| [aws_cloudwatch_metric_alarm.cpu_utilization_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilization_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS Cluster name where the service is deployed, used as dimension in CloudWatch alarm | `string` | n/a | yes |
| <a name="input_cpu_utilization_threshold"></a> [cpu\_utilization\_threshold](#input\_cpu\_utilization\_threshold) | The threshold for CPU utilization alarm to go off | `number` | `80` | no |
| <a name="input_create"></a> [create](#input\_create) | Variable to enable or disable alarms | `number` | `1` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold. | `number` | `3` | no |
| <a name="input_memory_utilization_threshold"></a> [memory\_utilization\_threshold](#input\_memory\_utilization\_threshold) | The threshold for Memory utilization alarm to go off | `number` | `80` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the alarm | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the specified statistic is applied. | `number` | `60` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | ECS Service name, used as dimension in CloudWatch alarm | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS Tags | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | The ARNs of the created CloudWatch alarms |
<!-- END_TF_DOCS -->