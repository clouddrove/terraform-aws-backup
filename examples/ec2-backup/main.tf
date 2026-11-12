locals {
  name        = "ec2-backup"
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
  description             = "KMS key for the EC2 backup vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/${local.name}-vault"
  policy                  = data.aws_iam_policy_document.kms.json
}

####----------------------------------------------------------------------------------
## EC2 instance - the resource that will be backed up.
####----------------------------------------------------------------------------------
module "ec2" {
  source  = "clouddrove/ec2/aws"
  version = "2.1.1"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  ####----------------------------------------------------------------------------------
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ####----------------------------------------------------------------------------------
  vpc_id            = module.vpc.vpc_id
  ssh_allowed_ip    = [module.vpc.vpc_cidr_block]
  ssh_allowed_ports = [22]

  # Instance
  instance_count = 1
  instance_configuration = {
    ami = {
      type         = "al2023"
      architecture = "arm64"
      region       = local.region
    }
    instance_type = "t4g.small"

    # Root volume
    root_block_device = [
      {
        volume_type           = "gp3"
        volume_size           = 15
        delete_on_termination = true
      }
    ]
  }

  # Networking
  subnet_ids = module.subnets.public_subnet_id

  # Keypair - supply your own public key (or set key_name for an existing key pair)
  # public_key = "ssh-rsa AAAA..."
}

####----------------------------------------------------------------------------------
## AWS Backup: vault + plan + IAM role + selection targeting the EC2 instance(s).
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

  # module.ec2.arn is a list (one ARN per instance)
  backup_resources = module.ec2.arn
  aws_backup_vault_policy_enabled = false
}
