locals {
  name        = "s3-backup"
  environment = "test"
  region      = "us-east-1"
  label_order = ["name", "environment"]
}

####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

####----------------------------------------------------------------------------------
## KMS key used to encrypt the AWS Backup vault.
####----------------------------------------------------------------------------------
data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "1.3.4"

  name                    = "${local.name}-kms"
  environment             = local.environment
  label_order             = local.label_order
  enabled                 = true
  description             = "KMS key for the S3 backup vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/${local.name}-vault"
  policy                  = data.aws_iam_policy_document.kms.json
}

####----------------------------------------------------------------------------------
## S3 bucket - the resource that will be backed up.
## NOTE: AWS Backup for S3 requires bucket versioning to be enabled.
####----------------------------------------------------------------------------------
module "s3" {
  source  = "clouddrove/s3/aws"
  version = "2.0.1"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  versioning = true
}

####----------------------------------------------------------------------------------
## AWS Backup: vault + plan + IAM role + selection targeting the S3 bucket.
####----------------------------------------------------------------------------------
module "backup" {
  source = "../../"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  enabled          = true
  vault_enabled    = true
  plan_enabled     = true
  iam_role_enabled = true
  kms_key_arn      = module.kms_key.key_arn

  # Fixed role name so the S3 policy below can be attached to it
  target_iam_role_name = "${local.name}-backup-role"

  schedule           = "cron(0 12 * * ? *)" # daily at 12:00 UTC
  start_window       = "60"
  completion_window  = "120"
  cold_storage_after = "30"
  delete_after       = "180"

  # No cross-region / cross-account copy
  destination_vault_arn = null

  backup_resources = [module.s3.arn]
}

####----------------------------------------------------------------------------------
## The backup module only attaches AWSBackupServiceRolePolicyForBackup to its role.
## Backing up S3 additionally needs the S3-specific managed policies.
####----------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "s3_backup" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = "${local.name}-backup-role"

  depends_on = [module.backup]
}

resource "aws_iam_role_policy_attachment" "s3_restore" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = "${local.name}-backup-role"

  depends_on = [module.backup]
}
