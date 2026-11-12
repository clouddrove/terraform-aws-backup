output "s3_bucket_id" {
  value       = module.s3.id
  description = "The name of the S3 bucket"
}

output "s3_bucket_arn" {
  value       = module.s3.arn
  description = "The ARN of the S3 bucket"
}

output "backup_id" {
  value       = module.backup.backup_id
  description = "The ID of the backup plan"
}

output "backup_vault_arn" {
  value       = module.backup.arn
  description = "The ARN of the backup plan"
}
