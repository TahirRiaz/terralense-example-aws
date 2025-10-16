output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = module.rds.db_instance_identifier
}

output "db_instance_address" {
  description = "Address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_endpoint" {
  description = "Connection endpoint for RDS instance"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = module.rds.db_instance_port
}

output "db_replica_id" {
  description = "ID of the RDS read replica"
  value       = module.rds_replica.db_instance_identifier
}

output "db_replica_address" {
  description = "Address of the RDS read replica"
  value       = module.rds_replica.db_instance_address
}

output "db_replica_endpoint" {
  description = "Connection endpoint for RDS read replica"
  value       = module.rds_replica.db_instance_endpoint
  sensitive   = true
}

output "db_name" {
  description = "Name of the database"
  value       = var.db_name
}

output "db_username" {
  description = "Master username for database"
  value       = var.db_username
  sensitive   = true
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_parameter_group_id" {
  description = "ID of the DB parameter group"
  value       = aws_db_parameter_group.postgres.id
}
