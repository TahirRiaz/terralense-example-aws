# VPC Module Wrapper
# This is a wrapper around the official Terraform AWS VPC module

module "vpc" {
  source  = "../vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.cidr

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group

  tags                 = var.tags
  public_subnet_tags   = var.public_subnet_tags
  private_subnet_tags  = var.private_subnet_tags
  database_subnet_tags = var.database_subnet_tags
}
