output "efs_id" {
  value       = module.efs.id
  description = "The ID of the EFS file system"
}

output "efs_arn" {
  value       = module.efs.arn
  description = "The ARN of the EFS file system"
}

output "efs_mount_target_ids" {
  value       = module.efs.mount_target_ids
  description = "The IDs of the EFS mount targets"
}

output "backup_id" {
  value       = module.backup.backup_id
  description = "The ID of the backup plan"
}

output "backup_vault_arn" {
  value       = module.backup.arn
  description = "The ARN of the backup plan"
}
