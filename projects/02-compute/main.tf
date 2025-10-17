locals {
  vpc_id                         = data.terraform_remote_state.networking.outputs.vpc_id
  public_subnet_ids              = data.terraform_remote_state.networking.outputs.public_subnet_ids
  private_subnet_ids             = data.terraform_remote_state.networking.outputs.private_subnet_ids
  application_security_group_id  = data.terraform_remote_state.networking.outputs.application_security_group_id
  alb_security_group_id          = data.terraform_remote_state.networking.outputs.alb_security_group_id
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name_prefix = "${var.environment}-ec2-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-ec2-role"
  }
}

# Attach SSM policy for Systems Manager access
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch policy
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${var.environment}-ec2-profile-"
  role        = aws_iam_role.ec2_role.name

  tags = {
    Name = "${var.environment}-ec2-profile"
  }
}

# Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  name               = "${var.environment}-alb"
  load_balancer_type = "application"

  vpc_id          = local.vpc_id
  subnets         = local.public_subnet_ids
  security_groups = [local.alb_security_group_id]

  enable_deletion_protection = false

  # Access logs
  access_logs = {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }

  target_groups = {
    web = {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = var.app_port
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = var.health_check_path
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-299"
      }

      create_attachment = false
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "web"
      }
    }
  }

  tags = {
    Name = "${var.environment}-alb"
  }
}

# S3 bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
  bucket_prefix = "${var.environment}-alb-logs-"

  tags = {
    Name = "${var.environment}-alb-logs"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ALB log delivery policy
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

# Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [local.application_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.environment}-web-server"
      Role = "web-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
module "asg" {
  source = "../../modules/autoscaling"

  name = "${var.environment}-web-asg"

  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  health_check_type   = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier = local.private_subnet_ids

  target_group_arns = [module.alb.target_groups["web"].arn]

  launch_template_name    = aws_launch_template.web.name
  launch_template_version = "$Latest"

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
  }

  # Scaling policies
  scaling_policies = {
    cpu-scale-up = {
      policy_type        = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 70.0
      }
    }
  }

  tags = {
    Name = "${var.environment}-web-asg"
  }
}
