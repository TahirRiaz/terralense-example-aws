# ALB Module Wrapper
# This is a wrapper around the official Terraform AWS ALB module

module "alb" {
  source  = "../alb/aws"
  version = "~> 9.0"

  name               = var.name
  load_balancer_type = var.load_balancer_type

  vpc_id          = var.vpc_id
  subnets         = var.subnets
  security_groups = var.security_groups

  enable_deletion_protection = var.enable_deletion_protection

  access_logs = var.access_logs

  target_groups = var.target_groups
  listeners     = var.listeners

  tags = var.tags
}
