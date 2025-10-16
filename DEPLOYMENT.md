# Deployment Guide

This guide walks through deploying the Terralense example AWS infrastructure.

## Prerequisites

1. **AWS Account**: You need an AWS account with appropriate permissions
2. **Terraform**: Install Terraform >= 1.5.0
3. **AWS CLI**: Install and configure AWS CLI with credentials
4. **S3 Backend**: Create an S3 bucket and DynamoDB table for state management

## Backend Setup

Before deploying, create the Terraform backend resources:

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket your-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket your-terraform-state-bucket \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

## Configuration

Update the S3 bucket name in all `backend.tf` files:

```bash
find . -name "backend.tf" -exec sed -i 's/your-terraform-state-bucket/ACTUAL-BUCKET-NAME/g' {} \;
```

## Deployment Order

Deploy projects in the following order due to dependencies:

### 1. Networking (01-networking)

```bash
cd projects/01-networking
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Outputs to note:**
- VPC ID
- Subnet IDs
- Security Group IDs
- Bastion public IP

### 2. Compute (02-compute)

```bash
cd ../02-compute
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Outputs to note:**
- ALB DNS name
- Auto Scaling Group name

### 3. Database (03-database)

```bash
cd ../03-database
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Outputs to note:**
- RDS endpoint
- Secrets Manager ARN

### 4. Monitoring (04-monitoring)

```bash
cd ../04-monitoring
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Outputs to note:**
- CloudWatch dashboard name
- SNS topic ARN

## Post-Deployment

### Access the Application

After deployment, access your application via the ALB DNS name:

```bash
# Get ALB DNS name
cd projects/02-compute
terraform output alb_dns_name
```

Visit `http://<alb-dns-name>` in your browser.

### Access the Bastion Host

```bash
# Get bastion IP
cd projects/01-networking
terraform output bastion_public_ip

# SSH to bastion (requires your SSH key)
ssh -i your-key.pem ec2-user@<bastion-ip>
```

### View CloudWatch Dashboard

```bash
# Get dashboard name
cd projects/04-monitoring
terraform output dashboard_name

# Open in AWS Console
aws cloudwatch get-dashboard --dashboard-name <dashboard-name>
```

### Get Database Credentials

```bash
# Get secret ARN
cd projects/03-database
terraform output db_secret_arn

# Retrieve credentials
aws secretsmanager get-secret-value --secret-id <secret-arn>
```

## Terraform State Management

### View State

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show <resource-address>
```

### Import Existing Resources

```bash
# Import an existing resource
terraform import <resource-address> <resource-id>
```

## Troubleshooting

### Common Issues

1. **Rate Limiting**: AWS API rate limits may cause temporary failures. Re-run `terraform apply`.

2. **Capacity Issues**: If ASG instances fail to launch, check:
   - EC2 service quotas
   - Available capacity in AZs
   - AMI availability

3. **Database Connection**: If can't connect to RDS:
   - Verify security group rules
   - Check subnet routing
   - Confirm bastion host can reach DB

### Debug Mode

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log
terraform apply
```

## Destroying Infrastructure

Destroy in reverse order:

```bash
# 4. Monitoring
cd projects/04-monitoring
terraform destroy

# 3. Database
cd ../03-database
terraform destroy

# 2. Compute
cd ../02-compute
terraform destroy

# 1. Networking
cd ../01-networking
terraform destroy
```

## Cost Optimization

To reduce costs during testing:

1. **Use smaller instances**:
   - Change `instance_type` to `t3.micro` or `t3.small`
   - Change `db_instance_class` to `db.t3.micro`

2. **Single NAT Gateway**:
   - In networking, set `single_nat_gateway = true`

3. **Disable Multi-AZ**:
   - In database, set `enable_multi_az = false`

4. **Reduce ASG capacity**:
   - Set `asg_desired_capacity = 1`

## Security Best Practices

1. **Restrict SSH access**: Update `allowed_ssh_cidrs` to your IP only
2. **Enable MFA**: Enable MFA delete on S3 state bucket
3. **Rotate credentials**: Regularly rotate database passwords
4. **Review security groups**: Minimize open ports and sources
5. **Enable CloudTrail**: Track all API calls
6. **Use VPC endpoints**: Reduce data transfer costs and improve security
