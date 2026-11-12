output "db_instance_id" {
  value       = module.mysql.db_instance_id
  description = "The RDS instance ID"
}

output "db_instance_arn" {
  value       = module.mysql.db_instance_arn
  description = "The ARN of the RDS instance"
}

output "db_instance_endpoint" {
  value       = module.mysql.db_instance_endpoint
  description = "The connection endpoint"
}

output "backup_id" {
  value       = module.backup.backup_id
  description = "The ID of the backup plan"
}

output "backup_vault_arn" {
  value       = module.backup.arn
  description = "The ARN of the backup plan"
}
