output "id" {
  value       = module.backup.id
  description = "A mapping of tags to assign to the id."

}

output "arn" {
  value       = module.backup.arn
  description = "A mapping of tags to assign to the arn."

}

output "tags" {
  value       = module.vpc.tags
  description = "A mapping of tags to assign to the resource."
}
output "backup_id" {
  value       = module.backup.backup_id
  description = "Backup Selection identifier."

}