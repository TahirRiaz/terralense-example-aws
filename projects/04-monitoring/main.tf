locals {
  alb_arn          = data.terraform_remote_state.compute.outputs.alb_arn
  target_group_arn = data.terraform_remote_state.compute.outputs.target_group_arn
  asg_name         = data.terraform_remote_state.compute.outputs.asg_name
  db_instance_id   = data.terraform_remote_state.database.outputs.db_instance_id
  db_replica_id    = data.terraform_remote_state.database.outputs.db_replica_id
  bastion_id       = data.terraform_remote_state.networking.outputs.bastion_instance_id
  nat_gateway_ids  = data.terraform_remote_state.networking.outputs.nat_gateway_ids

  # Extract load balancer name from ARN
  alb_suffix = split("/", local.alb_arn)[1]
  target_group_suffix = split(":", local.target_group_arn)[5]
}

# SNS Topic for alarms
resource "aws_sns_topic" "alarms" {
  name_prefix = "${var.environment}-alarms-"

  tags = {
    Name = "${var.environment}-alarms"
  }
}

resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-infrastructure"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Performance"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average", label = "Primary" }],
            ["AWS/RDS", "DatabaseConnections", { stat = "Average", label = "Connections" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average" }],
            ["AWS/AutoScaling", "GroupDesiredCapacity", { stat = "Average" }],
            [".", "GroupInServiceInstances", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Auto Scaling Group"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/NATGateway", "BytesOutToDestination", { stat = "Sum" }],
            [".", "BytesInFromDestination", { stat = "Sum" }],
            [".", "PacketsDropCount", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "NAT Gateway Traffic"
        }
      }
    ]
  })
}

# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.environment}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.alb_unhealthy_host_threshold
  alarm_description   = "This metric monitors unhealthy hosts in the target group"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    TargetGroup  = local.target_group_suffix
    LoadBalancer = local.alb_suffix
  }

  tags = {
    Name = "${var.environment}-alb-unhealthy-hosts"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${var.environment}-alb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.alb_response_time_threshold
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = local.alb_suffix
  }

  tags = {
    Name = "${var.environment}-alb-response-time"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "This metric monitors 5XX errors from targets"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_suffix
  }

  tags = {
    Name = "${var.environment}-alb-5xx-errors"
  }
}

# RDS Alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.environment}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags = {
    Name = "${var.environment}-rds-cpu"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${var.environment}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_free_storage_threshold
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags = {
    Name = "${var.environment}-rds-storage"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connection_count" {
  alarm_name          = "${var.environment}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors RDS database connections"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags = {
    Name = "${var.environment}-rds-connections"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_replica_lag" {
  alarm_name          = "${var.environment}-rds-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "This metric monitors RDS read replica lag"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = local.db_replica_id
  }

  tags = {
    Name = "${var.environment}-rds-replica-lag"
  }
}

# Auto Scaling Group Alarms
resource "aws_cloudwatch_metric_alarm" "asg_cpu" {
  alarm_name          = "${var.environment}-asg-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.asg_cpu_threshold
  alarm_description   = "This metric monitors ASG average CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = local.asg_name
  }

  tags = {
    Name = "${var.environment}-asg-cpu"
  }
}

# Bastion Host Alarms
resource "aws_cloudwatch_metric_alarm" "bastion_status_check" {
  alarm_name          = "${var.environment}-bastion-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "This metric monitors bastion host status checks"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = local.bastion_id
  }

  tags = {
    Name = "${var.environment}-bastion-status"
  }
}

# Log Groups for centralized logging
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/ec2/${var.environment}/application"
  retention_in_days = 30

  tags = {
    Name = "${var.environment}-application-logs"
  }
}

resource "aws_cloudwatch_log_group" "alb" {
  name              = "/aws/alb/${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "${var.environment}-alb-logs"
  }
}

# Log Metric Filters
resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "${var.environment}-error-count"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[ERROR]"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "TerralenseExample/${var.environment}"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "application_errors" {
  alarm_name          = "${var.environment}-application-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorCount"
  namespace           = "TerralenseExample/${var.environment}"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "This metric monitors application error count"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  tags = {
    Name = "${var.environment}-app-errors"
  }
}

# Composite Alarm for overall system health
resource "aws_cloudwatch_composite_alarm" "system_health" {
  alarm_name          = "${var.environment}-system-health"
  alarm_description   = "Composite alarm for overall system health"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarms.arn]

  alarm_rule = join(" OR ", [
    "ALARM(${aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.rds_cpu.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.rds_free_storage.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.bastion_status_check.alarm_name})"
  ])

  tags = {
    Name = "${var.environment}-system-health"
  }
}
