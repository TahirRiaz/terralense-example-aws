variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network"
  type        = string
  default     = "application"
}

variable "vpc_id" {
  description = "VPC ID where the load balancer will be deployed"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB"
  type        = list(string)
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB"
  type        = list(string)
  default     = []
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "access_logs" {
  description = "Map containing access logging configuration for load balancer"
  type        = map(string)
  default     = {}
}

variable "target_groups" {
  description = "Map of target group configurations"
  type        = any
  default     = {}
}

variable "listeners" {
  description = "Map of listener configurations"
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
