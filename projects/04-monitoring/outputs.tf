output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "application_log_group_name" {
  description = "Name of the application log group"
  value       = aws_cloudwatch_log_group.application.name
}

output "alb_log_group_name" {
  description = "Name of the ALB log group"
  value       = aws_cloudwatch_log_group.alb.name
}

output "composite_alarm_arn" {
  description = "ARN of the composite alarm for system health"
  value       = aws_cloudwatch_composite_alarm.system_health.arn
}

output "alarm_names" {
  description = "List of all alarm names"
  value = [
    aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name,
    aws_cloudwatch_metric_alarm.alb_response_time.alarm_name,
    aws_cloudwatch_metric_alarm.alb_5xx_errors.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.rds_free_storage.alarm_name,
    aws_cloudwatch_metric_alarm.rds_connection_count.alarm_name,
    aws_cloudwatch_metric_alarm.rds_replica_lag.alarm_name,
    aws_cloudwatch_metric_alarm.asg_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.bastion_status_check.alarm_name,
    aws_cloudwatch_metric_alarm.application_errors.alarm_name
  ]
}
