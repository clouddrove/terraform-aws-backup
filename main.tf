module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

locals {
  enabled          = var.enabled
  iam_role_enabled = local.enabled && var.iam_role_enabled
  plan_enabled     = local.enabled && var.plan_enabled
  vault_enabled    = local.enabled && var.vault_enabled
}

resource "aws_backup_vault" "default" {
  count       = local.vault_enabled ? 1 : 0
  name        = module.labels.id
  kms_key_arn = var.kms_key_arn
  tags        = module.labels.tags
}

resource "aws_backup_plan" "default" {
  count = local.plan_enabled ? 1 : 0
  name  = var.plan_name_suffix == null ? module.labels.id : format("%s_%s", module.labels.id, var.plan_name_suffix)

  rule {
    rule_name                = module.labels.id
    target_vault_name        = var.target_vault_name == null ? join("", aws_backup_vault.default[*].name) : var.target_vault_name
    schedule                 = var.schedule
    start_window             = var.start_window
    completion_window        = var.completion_window
    recovery_point_tags      = module.labels.tags
    enable_continuous_backup = var.enable_continuous_backup

    dynamic "lifecycle" {
      for_each = var.cold_storage_after != null || var.delete_after != null ? ["true"] : []
      content {
        cold_storage_after = var.cold_storage_after
        delete_after       = var.delete_after
      }
    }

    dynamic "copy_action" {
      for_each = var.destination_vault_arn != null ? ["true"] : []
      content {
        destination_vault_arn = var.destination_vault_arn

        dynamic "lifecycle" {
          for_each = var.copy_action_cold_storage_after != null || var.copy_action_delete_after != null ? ["true"] : []
          content {
            cold_storage_after = var.copy_action_cold_storage_after
            delete_after       = var.copy_action_delete_after
          }
        }
      }
    }
  }

  tags = module.labels.tags
}


data "aws_iam_policy_document" "aws_backup_vault_policy" {
  count = local.iam_role_enabled ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "backup:DescribeBackupVault",
      "backup:DeleteBackupVault",
      "backup:PutBackupVaultAccessPolicy",
      "backup:DeleteBackupVaultAccessPolicy",
      "backup:GetBackupVaultAccessPolicy",
      "backup:StartBackupJob",
      "backup:GetBackupVaultNotifications",
      "backup:PutBackupVaultNotifications",
    ]

    resources = [join("", aws_backup_vault.default[*].arn)]
  }
}

resource "aws_backup_vault_policy" "example" {
  count = var.aws_backup_vault_policy_enabled ? 1 : 0

  backup_vault_name = join("", aws_backup_vault.default[*].name)
  policy            = element(data.aws_iam_policy_document.aws_backup_vault_policy[*].json, count.index)
}

data "aws_iam_policy_document" "assume_role" {
  count = local.iam_role_enabled && var.aws_backup_vault_policy_enabled == false ? 1 : 0

  statement {
    sid     = "AWSBackupAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count = local.iam_role_enabled && var.aws_backup_vault_policy_enabled == false ? 1 : 0

  name               = var.target_iam_role_name == null ? module.labels.id : var.target_iam_role_name
  assume_role_policy = element(data.aws_iam_policy_document.assume_role[*].json, count.index)
  tags               = module.labels.tags
}

data "aws_iam_role" "existing" {
  count = local.enabled && var.iam_role_enabled == false ? 1 : 0

  name = module.labels.id
}

resource "aws_iam_role_policy_attachment" "default" {
  count      = local.iam_role_enabled && var.aws_backup_vault_policy_enabled == false ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = join("", aws_iam_role.default[*].name)
}

resource "aws_backup_selection" "default" {
  count        = local.plan_enabled && var.aws_backup_vault_policy_enabled == false ? 1 : 0
  name         = module.labels.id
  iam_role_arn = join("", var.iam_role_enabled ? aws_iam_role.default[*].arn : data.aws_iam_role.existing[*].arn)
  plan_id      = join("", aws_backup_plan.default[*].id)
  resources    = var.backup_resources
  dynamic "selection_tag" {
    for_each = var.selection_tags
    content {
      type  = selection_tag.value["type"]
      key   = selection_tag.value["key"]
      value = selection_tag.value["value"]
    }
  }
}

