output "autoscaling_group_id" {
  description = "The Auto Scaling Group id"
  value       = module.autoscaling.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The Auto Scaling Group name"
  value       = module.autoscaling.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "The ARN for this Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = module.autoscaling.autoscaling_group_desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.autoscaling.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = module.autoscaling.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = module.autoscaling.autoscaling_group_health_check_type
}

output "autoscaling_group_availability_zones" {
  description = "The availability zones of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_availability_zones
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "The VPC zone identifier"
  value       = module.autoscaling.autoscaling_group_vpc_zone_identifier
}
