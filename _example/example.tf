provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.15.0"

  vpc_enabled     = true
  enable_flow_log = false

  name        = "vpc"
  environment = "example"
  label_order = ["name", "environment"]

  cidr_block = "10.0.0.0/16"
}


module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "0.15.0"

  nat_gateway_enabled = true

  name        = "subnets"
  environment = "example"
  label_order = ["name", "environment"]

  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.vpc_id
  type               = "public-private"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

module "iam-role" {
  source = "clouddrove/iam-role/aws"

  name        = "iam"
  environment = "test"
  label_order = ["environment", "name"]

  assume_role_policy = data.aws_iam_policy_document.default.json

  policy_enabled = true
  policy         = data.aws_iam_policy_document.iam-policy.json
}

data "aws_iam_policy_document" "default" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam-policy" {
  statement {
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
    "ssmmessages:OpenDataChannel"]
    effect    = "Allow"
    resources = ["*"]
  }
}




module "efs" {
  source = "clouddrove/efs/aws"

  name        = "efs"
  environment = "example"
  label_order = ["name", "environment"]

  creation_token     = ""
  region             = ""
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.vpc_id
  subnets            = module.subnets.public_subnet_id
  security_groups    = [module.vpc.vpc_default_security_group_id]
}

module "backup" {
  source = "./.."

  name               = "test"
  environment        = "cd"
  label_order        = ["name", "environment"]
  schedule           = "cron(0 12 * * ? *)"
  start_window       = "60"
  completion_window  = "120"
  cold_storage_after = "30"
  delete_after       = "180"
  backup_resources   = [module.efs.arn]

}