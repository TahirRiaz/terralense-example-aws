variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = "alerts@example.com"
}

variable "alb_unhealthy_host_threshold" {
  description = "Threshold for unhealthy host count alarm"
  type        = number
  default     = 1
}

variable "alb_response_time_threshold" {
  description = "Threshold for ALB response time in seconds"
  type        = number
  default     = 1
}

variable "rds_cpu_threshold" {
  description = "Threshold for RDS CPU utilization percentage"
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold" {
  description = "Threshold for RDS free storage in bytes"
  type        = number
  default     = 5368709120 # 5GB
}

variable "asg_cpu_threshold" {
  description = "Threshold for ASG average CPU utilization percentage"
  type        = number
  default     = 80
}
