Creates default AWS CloudWatch alarm for Application Load Balancer

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
| [aws_cloudwatch_metric_alarm.HTTPCode_ELB_503_Count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.httpcode_target_5xx_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_response_time_average](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_critical_sns_topic_arns"></a> [critical\_sns\_topic\_arns](#input\_critical\_sns\_topic\_arns) | List of SNS topic ARNs which we'll use to send critical messages | `list(string)` | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Variable to enable or disable alarms | `bool` | `true` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold. | `number` | `3` | no |
| <a name="input_httpcode_target_5xx_count"></a> [httpcode\_target\_5xx\_count](#input\_httpcode\_target\_5xx\_count) | The threashold for 5xx errors. | `map(string)` | <pre>{<br/>  "critical": 10,<br/>  "warning": 1<br/>}</pre> | no |
| <a name="input_lb_arn_suffix"></a> [lb\_arn\_suffix](#input\_lb\_arn\_suffix) | ARN for load balancer, this converts to LoadBalancer name used as dimension in CloudWatch alarm | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the alarm | `string` | n/a | yes |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the specified statistic is applied. | `number` | `60` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS Tags | `map` | `{}` | no |
| <a name="input_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#input\_target\_group\_arn\_suffix) | ARN for target group, e.g. aws\_lb\_target\_group.this.arn\_suffix | `string` | n/a | yes |
| <a name="input_target_response_time"></a> [target\_response\_time](#input\_target\_response\_time) | The avarage response time in seconds over which the alarm is applied. | `map(string)` | <pre>{<br/>  "critical": 2,<br/>  "warning": 1<br/>}</pre> | no |
| <a name="input_warning_sns_topic_arns"></a> [warning\_sns\_topic\_arns](#input\_warning\_sns\_topic\_arns) | List of SNS topic ARNs which we'll use to send warning messages | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | The ARNs of the created CloudWatch alarms |
<!-- END_TF_DOCS -->