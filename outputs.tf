output "id" {
  value       = join("", aws_backup_plan.default.*.id)
  description = "A mapping of tags to assign to the key."
  sensitive   = true
}

output "arn" {
  value       = join("", aws_backup_plan.default.*.arn)
  description = "A mapping of tags to assign to the certificate."
  sensitive   = true
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
