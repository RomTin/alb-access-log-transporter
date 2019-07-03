## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_name | alb name | string | n/a | yes |
| prefix | name prefix | string | n/a | yes |
| region | region name | string | n/a | yes |
| slack\_channel | webhook endpoint for slack channel | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_log\_bucket\_arn | Bucket ARN of ALB logs |
| alb\_log\_bucket\_id | Bucket ID of ALB logs |
| alb\_log\_bucket\_name | Bucket name of ALB logs |

