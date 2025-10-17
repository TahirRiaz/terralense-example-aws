variable "name" {
  description = "Name used across the resources created"
  type        = string
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
}

variable "health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}

variable "target_group_arns" {
  description = "A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
  default     = []
}

variable "launch_template_name" {
  description = "Name of the launch template to use"
  type        = string
  default     = null
}

variable "launch_template_version" {
  description = "Launch template version. Can be version number, $Latest or $Default"
  type        = string
  default     = null
}

variable "instance_refresh" {
  description = "If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated"
  type        = any
  default     = {}
}

variable "scaling_policies" {
  description = "Map of scaling policies to create"
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
