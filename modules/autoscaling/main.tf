# Auto Scaling Module Wrapper
# This is a wrapper around the official Terraform AWS Auto Scaling module

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 7.0"

  name = var.name

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  vpc_zone_identifier       = var.vpc_zone_identifier

  target_group_arns = var.target_group_arns

  launch_template_name    = var.launch_template_name
  launch_template_version = var.launch_template_version

  instance_refresh = var.instance_refresh
  scaling_policies = var.scaling_policies

  tags = var.tags
}
