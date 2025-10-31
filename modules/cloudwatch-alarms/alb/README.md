CloudWatch ALB Alarms

## Inputs

| Name                       | Description                                                                                                                                                     | Type     | Default | Required |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| alarm\_actions             | The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list`   | `[]`    |    no    |
| create                     | Variable to enable or disable alarms                                                                                                                            | `number` | `1`     |    no    |
| lb\_arn\_suffix            | n/a                                                                                                                                                             | `string` | n/a     |   yes    |
| name                       | Name for the alarm                                                                                                                                              | `string` | n/a     |   yes    |
| ok\_actions                | The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN).    | `list`   | `[]`    |    no    |
| tags                       | AWS Tags                                                                                                                                                        | `map`    | `{}`    |    no    |
| target\_group\_arn\_suffix | ARN for target group, e.g. aws\_lb\_target\_group.this.arn\_suffix                                                                                              | `string` | n/a     |   yes    |

## Outputs

| Name        | Description |
| ----------- | ----------- |
| alarm\_arns | n/a         |
