<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS Backup
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create backup backup resource on AWS.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.15-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="Licence">
</a>
<a href="https://github.com/clouddrove/terraform-aws-buckup/actions/workflows/tfsec.yml">
  <img src="https://github.com/clouddrove/terraform-aws-buckup/actions/workflows/tfsec.yml/badge.svg" alt="tfsec">
</a>
<a href="https://github.com/clouddrove/terraform-aws-buckup/actions/workflows/terraform.yml">
  <img src="https://github.com/clouddrove/terraform-aws-buckup/actions/workflows/terraform.yml/badge.svg" alt="static-checks">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-aws-backup'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+Backup&url=https://github.com/clouddrove/terraform-aws-backup'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+Backup&url=https://github.com/clouddrove/terraform-aws-backup'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 1.x.x](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-backup/releases).


### Simple Example
Here is an example of how you can use this module in your inventory structure:
  ```hcl
  module "backup" {
      source             = "clouddrove/backup/aws"
      version            = "0.15.0"
      name               = "clouddrove"
      environment        = "test"
      label_order        = ["name", "environment"]
      schedule           = "cron(0 12 * * ? *)"
      start_window       = "60"
      completion_window  = "120"
      cold_storage_after = "30"
      delete_after       = "180"
      backup_resources   = [module.efs.arn]
    }
  ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| aws\_backup\_vault\_policy\_enabled | The backup vault access policy document in JSON format. | `bool` | `true` | no |
| backup\_resources | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(string)` | `[]` | no |
| cold\_storage\_after | Specifies the number of days after creation that a recovery point is moved to cold storage | `string` | `null` | no |
| completion\_window | The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Must be at least 60 minutes greater than `start_window` | `string` | `null` | no |
| copy\_action\_cold\_storage\_after | For copy operation, specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| copy\_action\_delete\_after | For copy operation, specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `copy_action_cold_storage_after` | `number` | `null` | no |
| delete\_after | Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after` | `string` | `null` | no |
| delimiter | Delimiter to be used between `organization`, `environment`, `name` and `attributes`. | `string` | `"-"` | no |
| destination\_vault\_arn | An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup | `string` | `""` | no |
| enable\_continuous\_backup | Enable continuous backups for supported resources. | `bool` | `false` | no |
| enabled | backup Name | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| iam\_role\_enabled | Should we create a new Iam Role and Policy Attachment | `bool` | `true` | no |
| kms\_key\_arn | The server-side encryption key that is used to protect your backups | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
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




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-aws-backup/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-aws-backup)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
