output "id" {
  description = "The ID and ARN of the load balancer"
  value       = module.alb.id
}

output "arn" {
  description = "The ARN of the load balancer"
  value       = module.alb.arn
}

output "arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = module.alb.arn_suffix
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = module.alb.zone_id
}

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value       = module.alb.target_groups
}

output "listeners" {
  description = "Map of listeners created and their attributes"
  value       = module.alb.listeners
}

output "security_group_id" {
  description = "Security group ID attached to the load balancer"
  value       = try(module.alb.security_group_id, null)
}
