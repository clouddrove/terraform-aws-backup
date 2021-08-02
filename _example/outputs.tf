output "id" {
  value       = module.backup.id
  description = "A mapping of tags to assign to the id."
  sensitive   = true
}

output "arn" {
  value       = module.backup.arn
  description = "A mapping of tags to assign to the arn."
  sensitive   = true
}

output "tags" {
  value       = module.vpc.tags
  description = "A mapping of tags to assign to the resource."
}
