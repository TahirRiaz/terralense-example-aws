# RDS Module Wrapper
# This is a wrapper around the official Terraform AWS RDS module

module "rds" {
  source  = "../rds/aws"
  version = "~> 6.0"

  identifier = var.identifier

  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family
  major_engine_version = var.major_engine_version
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  multi_az               = var.multi_az
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group     = var.create_cloudwatch_log_group

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  parameters = var.parameters

  replicate_source_db = var.replicate_source_db

  create_db_subnet_group    = var.create_db_subnet_group
  create_db_parameter_group = var.create_db_parameter_group

  tags = var.tags
}
