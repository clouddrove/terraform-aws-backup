locals {
  name        = "rds-backup"
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
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
####----------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.5"

  name            = "${local.name}-vpc"
  environment     = local.environment
  label_order     = local.label_order
  enable_flow_log = false
  cidr_block      = "10.0.0.0/16"
}

####----------------------------------------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
####----------------------------------------------------------------------------------
module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.3"

  name        = "${local.name}-subnets"
  environment = local.environment
  label_order = local.label_order

  availability_zones = ["${local.region}a", "${local.region}b"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

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
  description             = "KMS key for the RDS backup vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/${local.name}-vault"
  policy                  = data.aws_iam_policy_document.kms.json
}

####----------------------------------------------------------------------------------
## RDS MySQL instance (CloudDrove mysql module) - the resource that will be backed up.
####----------------------------------------------------------------------------------
module "mysql" {
  source  = "clouddrove/mysql/aws"
  version = "1.3.4"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  engine            = "mysql"
  engine_version    = "8.4.9"
  instance_class    = "db.t3.small"
  allocated_storage = 20

  ####----------------------------------------------------------------------------------
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ####----------------------------------------------------------------------------------
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [3306]

  # DB Details
  db_name  = "test"
  username = "user"
  password = "" # -- Leave empty to have the module generate one (see complete-mysql example)
  port     = "3306"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00" # native RDS automated backups, must not overlap maintenance_window
  multi_az           = false

  # Native RDS automated backups are kept alongside the AWS Backup plan below
  backup_retention_period = 7

  enabled_cloudwatch_logs_exports = ["audit", "general"]

  # No read replica for this example
  enabled_read_replica = false

  # DB subnet group
  subnet_ids          = module.subnets.public_subnet_id
  publicly_accessible = false

  # Database Deletion Protection
  deletion_protection = false

  # DB parameter group
  enabled_parameter_group = true
  family                  = "mysql8.4"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]
}

####----------------------------------------------------------------------------------
## AWS Backup: vault + plan + IAM role + selection targeting the RDS instance.
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

  schedule           = "cron(0 12 * * ? *)" # daily at 12:00 UTC
  start_window       = "60"
  completion_window  = "120"
  cold_storage_after = "30"
  delete_after       = "180"

  # No cross-region / cross-account copy
  destination_vault_arn = null
  aws_backup_vault_policy_enabled = false
  backup_resources = [module.mysql.db_instance_arn]
}
