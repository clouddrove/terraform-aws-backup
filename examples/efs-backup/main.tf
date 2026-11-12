locals {
  name        = "efs-backup"
  environment = "test"
  region      = "us-east-1"
  label_order = ["name", "environment"]
  azs         = ["${local.region}a", "${local.region}b"]
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

  availability_zones = local.azs
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

####----------------------------------------------------------------------------------
## Security group allowing NFS (2049) traffic from inside the VPC to the EFS mount targets.
####----------------------------------------------------------------------------------
module "efs_sg" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.3"

  name        = "${local.name}-sg"
  environment = local.environment
  label_order = local.label_order
  vpc_id      = module.vpc.vpc_id

  new_sg_ingress_rules = [{
    key         = "nfs-from-vpc"
    ip_protocol = "tcp"
    from_port   = 2049
    to_port     = 2049
    cidr_ipv4   = module.vpc.vpc_cidr_block
    description = "Allow NFS traffic from within the VPC."
  }]
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
  description             = "KMS key for the EFS backup vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/${local.name}-vault"
  policy                  = data.aws_iam_policy_document.kms.json
}

####----------------------------------------------------------------------------------
## Amazon Elastic File System (EFS) - the resource that will be backed up.
####----------------------------------------------------------------------------------
module "efs" {
  source  = "clouddrove/efs/aws"
  version = "2.0.1"

  name        = "${local.name}-efs"
  environment = local.environment
  label_order = local.label_order

  creation_token     = "${local.name}-token"
  availability_zones = local.azs
  vpc_id             = module.vpc.vpc_id
  subnets            = module.subnets.public_subnet_id
  security_groups    = [module.efs_sg.security_group_id]
  replication_enabled = false
}

####----------------------------------------------------------------------------------
## AWS Backup: vault + plan + IAM role + selection targeting the EFS file system.
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

  backup_resources = [module.efs.arn]
  aws_backup_vault_policy_enabled = false
}
