variable "name" {
  type        = string
  default     = ""
  description = "backup Name"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "backup Name"
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-backup"
  description = "Terraform current module repo"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "The server-side encryption key that is used to protect your backups"

}

variable "schedule" {
  type        = string
  default     = null
  description = "A CRON expression specifying when AWS Backup initiates a backup job"

}

variable "start_window" {
  type        = string
  default     = null
  description = "The amount of time in minutes before beginning a backup. Minimum value is 60 minutes"

}

variable "completion_window" {
  type        = string
  default     = null
  description = "The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Must be at least 60 minutes greater than `start_window`"

}

variable "cold_storage_after" {
  type        = string
  default     = null
  description = "Specifies the number of days after creation that a recovery point is moved to cold storage"

}

variable "delete_after" {
  type        = string
  default     = null
  description = "Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after`"

}

variable "backup_resources" {
  type        = list(string)
  default     = []
  description = "An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan"

}

variable "selection_tags" {
  type = list(object({
    type  = string
    key   = string
    value = string
  }))
  default     = []
  description = "An array of tag condition objects used to filter resources based on tags for assigning to a backup plan"

}

variable "destination_vault_arn" {
  type        = string
  default     = ""
  description = "An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup"

}

variable "copy_action_cold_storage_after" {
  type        = number
  default     = null
  description = "For copy operation, specifies the number of days after creation that a recovery point is moved to cold storage"

}

variable "copy_action_delete_after" {
  type        = number
  default     = null
  description = "For copy operation, specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `copy_action_cold_storage_after`"

}

variable "plan_name_suffix" {
  type        = string
  default     = null
  description = "The string appended to the plan name"

}

variable "target_vault_name" {
  type        = string
  default     = null
  description = "Override target Vault Name"

}

variable "vault_enabled" {
  type        = bool
  default     = true
  description = "Should we create a new Vault"

}

variable "plan_enabled" {
  type        = bool
  default     = true
  description = "Should we create a new Plan"

}

variable "iam_role_enabled" {
  type        = bool
  default     = true
  description = "Should we create a new Iam Role and Policy Attachment"

}

variable "target_iam_role_name" {
  type        = string
  default     = null
  description = "Override target IAM Role Name"

}

variable "enable_continuous_backup" {
  type        = bool
  default     = false
  description = "Enable continuous backups for supported resources."

}
variable "aws_backup_vault_policy_enabled" {
  type        = bool
  default     = true
  description = "The backup vault access policy document in JSON format."

}