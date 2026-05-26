## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_backup\_vault\_policy\_enabled | The backup vault access policy document in JSON format. | `bool` | `true` | no |
| backup\_resources | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(string)` | `[]` | no |
| cold\_storage\_after | Specifies the number of days after creation that a recovery point is moved to cold storage | `string` | `null` | no |
| completion\_window | The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Must be at least 60 minutes greater than `start_window` | `string` | `null` | no |
| copy\_action\_cold\_storage\_after | For copy operation, specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| copy\_action\_delete\_after | For copy operation, specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `copy_action_cold_storage_after` | `number` | `null` | no |
| delete\_after | Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after` | `string` | `null` | no |
| destination\_vault\_arn | An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup | `string` | `""` | no |
| enable\_continuous\_backup | Enable continuous backups for supported resources. | `bool` | `false` | no |
| enabled | backup Name | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| iam\_role\_enabled | Should we create a new Iam Role and Policy Attachment | `bool` | `true` | no |
| kms\_key\_arn | The server-side encryption key that is used to protect your backups | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| name | backup Name | `string` | `""` | no |
| plan\_enabled | Should we create a new Plan | `bool` | `true` | no |
| plan\_name\_suffix | The string appended to the plan name | `string` | `null` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-backup"` | no |
| schedule | A CRON expression specifying when AWS Backup initiates a backup job | `string` | `null` | no |
| selection\_tags | An array of tag condition objects used to filter resources based on tags for assigning to a backup plan | <pre>list(object({<br>    type  = string<br>    key   = string<br>    value = string<br>  }))</pre> | `[]` | no |
| start\_window | The amount of time in minutes before beginning a backup. Minimum value is 60 minutes | `string` | `null` | no |
| target\_iam\_role\_name | Override target IAM Role Name | `string` | `null` | no |
| target\_vault\_name | Override target Vault Name | `string` | `null` | no |
| vault\_enabled | Should we create a new Vault | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | A mapping of tags to assign to the certificate. |
| backup\_id | Backup Selection identifier. |
| id | A mapping of tags to assign to the key. |
| tags | A mapping of tags to assign to the resource. |

