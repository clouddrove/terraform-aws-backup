output "instance_id" {
  value       = module.ec2.instance_id
  description = "The ID(s) of the EC2 instance(s)"
}

output "instance_arn" {
  value       = module.ec2.arn
  description = "The ARN(s) of the EC2 instance(s)"
}

output "private_ip" {
  value       = module.ec2.private_ip
  description = "The private IP address(es) of the EC2 instance(s)"
}

output "backup_id" {
  value       = module.backup.backup_id
  description = "The ID of the backup plan"
}

output "backup_vault_arn" {
  value       = module.backup.arn
  description = "The ARN of the backup plan"
}
