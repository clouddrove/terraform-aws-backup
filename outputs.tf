output "id" {
  value       = join("", aws_backup_plan.default[*].id)
  description = "A mapping of tags to assign to the key."

}

output "arn" {
  value       = join("", aws_backup_plan.default[*].arn)
  description = "A mapping of tags to assign to the certificate."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
output "backup_id" {
  value       = join("", aws_backup_selection.default[*].id)
  description = "Backup Selection identifier."
}