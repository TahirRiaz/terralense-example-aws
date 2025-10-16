# Terralense Example AWS - Project Structure

## Complete File Tree

```
terralense-example-aws/
├── README.md                          # Main documentation
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore rules
├── DEPLOYMENT.md                      # Deployment guide
├── CONTRIBUTING.md                    # Contribution guidelines
├── PROJECT_STRUCTURE.md               # This file
│
├── projects/                          # Multi-project structure
│   │
│   ├── 01-networking/                 # Foundation networking layer
│   │   ├── backend.tf                 # S3 backend configuration
│   │   ├── versions.tf                # Terraform/provider versions
│   │   ├── variables.tf               # Input variables
│   │   ├── main.tf                    # VPC, subnets, security groups, bastion
│   │   └── outputs.tf                 # Outputs for dependent projects
│   │
│   ├── 02-compute/                    # Application compute layer
│   │   ├── backend.tf                 # S3 backend configuration
│   │   ├── versions.tf                # Terraform/provider versions
│   │   ├── data.tf                    # Remote state from networking
│   │   ├── variables.tf               # Input variables
│   │   ├── main.tf                    # ALB, ASG, Launch Templates
│   │   ├── user_data.sh               # EC2 user data script
│   │   └── outputs.tf                 # Outputs for monitoring
│   │
│   ├── 03-database/                   # Database layer
│   │   ├── backend.tf                 # S3 backend configuration
│   │   ├── versions.tf                # Terraform/provider versions
│   │   ├── data.tf                    # Remote state from networking
│   │   ├── variables.tf               # Input variables
│   │   ├── main.tf                    # RDS primary + replica, Secrets Manager
│   │   └── outputs.tf                 # Outputs for monitoring
│   │
│   └── 04-monitoring/                 # Observability layer
│       ├── backend.tf                 # S3 backend configuration
│       ├── versions.tf                # Terraform/provider versions
│       ├── data.tf                    # Remote state from all projects
│       ├── variables.tf               # Input variables
│       ├── main.tf                    # CloudWatch dashboards, alarms, logs
│       └── outputs.tf                 # Monitoring outputs
│
└── modules/                           # Reusable modules
    │
    ├── security-group/                # Security group module
    │   ├── main.tf                    # SG resources with dynamic rules
    │   ├── variables.tf               # Module inputs
    │   └── outputs.tf                 # SG ID, ARN, name
    │
    ├── ec2-instance/                  # EC2 instance module
    │   ├── main.tf                    # Instance with AMI lookup
    │   ├── variables.tf               # Module inputs
    │   └── outputs.tf                 # Instance details
    │
    └── vpc/                           # VPC wrapper module
        └── README.md                  # Module documentation
```

## Project Dependencies

### Dependency Graph

```
┌─────────────────┐
│  01-networking  │
│                 │
│  - VPC          │
│  - Subnets      │
│  - Security     │
│    Groups       │
│  - Bastion      │
│  - NAT Gateway  │
└────────┬────────┘
         │
         │ (remote state)
         │
    ┌────┴────────────────────┐
    │                         │
    ▼                         ▼
┌─────────────┐      ┌──────────────┐
│ 02-compute  │      │ 03-database  │
│             │      │              │
│ - ALB       │      │ - RDS        │
│ - ASG       │      │ - Replica    │
│ - EC2       │      │ - Secrets    │
└──────┬──────┘      └──────┬───────┘
       │                    │
       │ (remote state)     │
       │                    │
       └────────┬───────────┘
                │
                ▼
        ┌──────────────┐
        │ 04-monitoring│
        │              │
        │ - Dashboard  │
        │ - Alarms     │
        │ - Logs       │
        └──────────────┘
```

### Cross-Project References

**02-compute** reads from **01-networking**:
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `application_security_group_id`
- `alb_security_group_id`

**03-database** reads from **01-networking**:
- `vpc_id`
- `database_subnet_ids`
- `database_subnet_group_name`
- `database_security_group_id`

**04-monitoring** reads from:
- **01-networking**: `bastion_instance_id`, `nat_gateway_ids`
- **02-compute**: `alb_arn`, `target_group_arn`, `asg_name`
- **03-database**: `db_instance_id`, `db_replica_id`

## Public Modules Used

1. **terraform-aws-modules/vpc/aws** (v5.0)
   - Used in: `projects/01-networking/main.tf`
   - Purpose: VPC with subnets, NAT, flow logs

2. **terraform-aws-modules/alb/aws** (v9.0)
   - Used in: `projects/02-compute/main.tf`
   - Purpose: Application Load Balancer

3. **terraform-aws-modules/autoscaling/aws** (v7.0)
   - Used in: `projects/02-compute/main.tf`
   - Purpose: Auto Scaling Group with policies

4. **terraform-aws-modules/rds/aws** (v6.0)
   - Used in: `projects/03-database/main.tf`
   - Purpose: RDS PostgreSQL primary and replica

## Resource Count by Project

### 01-networking
- 1 VPC (via module)
- 9 Subnets (3 public, 3 private, 3 database)
- 4 Security Groups
- 1 Bastion EC2 instance
- 1 Elastic IP
- 2 NAT Gateways
- 1 VPC Endpoint (S3)
- **~20+ resources**

### 02-compute
- 1 Application Load Balancer
- 1 Target Group
- 1 Auto Scaling Group
- 1 Launch Template
- 1 IAM Role + Profile
- 2 IAM Policy Attachments
- 1 S3 Bucket (ALB logs)
- **~15+ resources**

### 03-database
- 1 RDS Primary Instance
- 1 RDS Read Replica
- 1 DB Parameter Group
- 1 Secrets Manager Secret
- 1 Random Password
- **~10+ resources**

### 04-monitoring
- 1 CloudWatch Dashboard
- 10 CloudWatch Alarms
- 1 Composite Alarm
- 2 Log Groups
- 1 Log Metric Filter
- 1 SNS Topic
- 1 SNS Subscription
- **~15+ resources**

**Total: ~60-70 AWS resources**

## File Statistics

```
Total Files: 35
- Terraform files (.tf): 27
- Documentation (.md): 5
- Shell scripts (.sh): 1
- Config files: 2 (.gitignore, LICENSE)
```

## State Management

All projects use:
- **Backend**: S3 with encryption
- **Locking**: DynamoDB table
- **State Keys**:
  - `networking/terraform.tfstate`
  - `compute/terraform.tfstate`
  - `database/terraform.tfstate`
  - `monitoring/terraform.tfstate`

## Key Features for Terralense

1. **Multi-Project Architecture**: 4 distinct projects with clear boundaries
2. **Remote State Dependencies**: All cross-project refs use `terraform_remote_state`
3. **Public Module Usage**: 4 official modules from Terraform Registry
4. **Local Modules**: 3 reusable custom modules
5. **Realistic Patterns**: Production-grade AWS architecture
6. **Complete Documentation**: README, deployment guide, contribution guide
7. **Valid Terraform**: All syntax verified, no placeholders
8. **Security Best Practices**: Encryption, IMDSv2, least privilege

## Next Steps

1. Update S3 bucket name in all `backend.tf` files
2. Review and customize variables as needed
3. Deploy in order: networking → compute → database → monitoring
4. Use Terralense to analyze the dependency graph
5. Push to GitHub for showcase

## Deployment Order

**MUST deploy in this order due to dependencies:**

1. `projects/01-networking` (no dependencies)
2. `projects/02-compute` (depends on networking)
3. `projects/03-database` (depends on networking)
4. `projects/04-monitoring` (depends on all above)

**Destruction order (reverse):**

1. `projects/04-monitoring`
2. `projects/03-database`
3. `projects/02-compute`
4. `projects/01-networking`
