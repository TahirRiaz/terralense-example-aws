locals {
  vpc_id                        = data.terraform_remote_state.networking.outputs.vpc_id
  database_subnet_ids           = data.terraform_remote_state.networking.outputs.database_subnet_ids
  database_subnet_group_name    = data.terraform_remote_state.networking.outputs.database_subnet_group_name
  database_security_group_id    = data.terraform_remote_state.networking.outputs.database_security_group_id
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name_prefix             = "${var.environment}-db-password-"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.environment}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = module.rds.db_instance_address
    port     = module.rds.db_instance_port
    dbname   = var.db_name
  })
}

# RDS PostgreSQL Instance using official module
module "rds" {
  source  = ".modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.environment}-postgres"

  engine               = "postgres"
  engine_version       = "15.4"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = 5432

  multi_az               = var.enable_multi_az
  db_subnet_group_name   = local.database_subnet_group_name
  vpc_security_group_ids = [local.database_security_group_id]

  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  deletion_protection = false
  skip_final_snapshot = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  parameters = [
    {
      name  = "autovacuum"
      value = "1"
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = {
    Name = "${var.environment}-postgres"
  }
}

# RDS Read Replica for scaling reads
module "rds_replica" {
  source  = ".modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.environment}-postgres-replica"

  replicate_source_db = module.rds.db_instance_identifier

  engine               = "postgres"
  engine_version       = "15.4"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted     = true

  port = 5432

  multi_az               = false
  vpc_security_group_ids = [local.database_security_group_id]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  create_db_subnet_group = false
  create_db_parameter_group = false

  tags = {
    Name = "${var.environment}-postgres-replica"
    Role = "read-replica"
  }
}

# Parameter Group for custom configurations
resource "aws_db_parameter_group" "postgres" {
  name_prefix = "${var.environment}-postgres-"
  family      = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = {
    Name = "${var.environment}-postgres-params"
  }

  lifecycle {
    create_before_destroy = true
  }
}
