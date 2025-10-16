#!/bin/bash
set -e

# Update system
yum update -y

# Install Apache and PHP
yum install -y httpd php

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Create a simple web page
cat > /var/www/html/index.php <<'EOF'
<?php
$instance_id = file_get_contents("http://169.254.169.254/latest/meta-data/instance-id");
$availability_zone = file_get_contents("http://169.254.169.254/latest/meta-data/placement/availability-zone");
?>
<!DOCTYPE html>
<html>
<head>
    <title>Terralense Example - ${environment}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .info { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Terralense Example Application</h1>
    <div class="info">
        <h2>Instance Information</h2>
        <p><strong>Environment:</strong> ${environment}</p>
        <p><strong>Instance ID:</strong> <?php echo $instance_id; ?></p>
        <p><strong>Availability Zone:</strong> <?php echo $availability_zone; ?></p>
    </div>
</body>
</html>
EOF

# Create health check endpoint
cat > /var/www/html/health <<'EOF'
OK
EOF

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'CWCONFIG'
{
  "metrics": {
    "namespace": "TerralenseExample/${environment}",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
          {"name": "cpu_usage_iowait", "rename": "CPU_IOWAIT", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DISK_USED", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MEM_USED", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
CWCONFIG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
