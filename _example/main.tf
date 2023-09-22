provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  enable_flow_log = false

  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]

  cidr_block = "10.0.0.0/16"
}


module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.0"

  nat_gateway_enabled = true

  name        = "subnets"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.vpc_id
  type               = "public-private"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}


module "ssh" {
  source      = "clouddrove/security-group/aws"
  version     = "2.0.0"
  name        = "ssh"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id

  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [module.vpc.vpc_cidr_block, "0.0.0.0/0"]
    description = "Allow ssh traffic."
    }]
}


module "efs" {
  source  = "clouddrove/efs/aws"
  version = "1.3.1"

  name        = "efs"
  environment = "test"
  label_order = ["name", "environment"]

  creation_token     = ""
  region             = ""
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.vpc_id
  subnets            = module.subnets.public_subnet_id
  security_groups    = [module.ssh.security_group_ids]
}

module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "1.3.1"

  name                    = "kms"
  environment             = "test"
  label_order             = ["environment", "name"]
  enabled                 = true
  description             = "KMS key for ec2"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/ec3"
  policy                  = data.aws_iam_policy_document.kms.json
}


data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

}

module "backup" {
  source = "./.."

  name        = "backup"
  environment = "test"
  label_order = ["name", "environment"]

  enabled               = true
  vault_enabled         = true
  plan_enabled          = true
  iam_role_enabled      = true
  schedule              = "cron(0 12 * * ? *)"
  start_window          = "60"
  completion_window     = "120"
  cold_storage_after    = "30"
  destination_vault_arn = ""
  delete_after          = "180"
  backup_resources      = [module.efs.arn]
  kms_key_arn           = module.kms_key.key_arn

}
