# Terralense Example AWS Repository

This is a multi-project Terraform repository demonstrating complex cross-project dependencies in AWS infrastructure. It's designed to showcase the capabilities of [Terralense](https://github.com/yourusername/terralense), a Terraform productivity tool for analyzing dependencies within and across projects.

## Repository Structure

- **projects/01-networking**: Core networking infrastructure (VPC, subnets, security groups, bastion hosts)
- **projects/02-compute**: Compute resources (EC2 instances, Auto Scaling Groups, Application Load Balancer)
- **projects/03-database**: Database layer (RDS PostgreSQL instances)
- **projects/04-monitoring**: Monitoring and alerting (CloudWatch dashboards and alarms)
- **modules**: Reusable Terraform modules shared across projects

## Cross-Project Dependencies

This repository demonstrates realistic cross-project dependencies:

- **Compute** depends on **Networking** (VPC, subnets, security groups)
- **Database** depends on **Networking** (VPC, subnets, security groups)
- **Monitoring** depends on **Compute** and **Database** (resource IDs for monitoring)

Dependencies are managed using Terraform remote state with S3 backend.

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with appropriate credentials
- S3 bucket for Terraform state storage
- DynamoDB table for state locking

## Setup Instructions

1. **Configure Backend**: Update the S3 bucket name in each project's `backend.tf`

2. **Deploy in Order**:
   ```bash
   # 1. Networking
   cd projects/01-networking
   terraform init
   terraform plan
   terraform apply

   # 2. Compute
   cd ../02-compute
   terraform init
   terraform plan
   terraform apply

   # 3. Database
   cd ../03-database
   terraform init
   terraform plan
   terraform apply

   # 4. Monitoring
   cd ../04-monitoring
   terraform init
   terraform plan
   terraform apply
   ```

## Using Terralense

Analyze dependencies across projects:
```bash
terralense analyze --path . --output dependencies.json
terralense visualize --input dependencies.json
```

## Cost Considerations

This infrastructure will incur AWS costs. Key resources:
- NAT Gateways (~$90/month)
- Application Load Balancer (~$25/month)
- EC2 instances (varies by instance type)
- RDS instances (varies by instance type)

Remember to destroy resources when not needed:
```bash
cd projects/04-monitoring && terraform destroy
cd ../03-database && terraform destroy
cd ../02-compute && terraform destroy
cd ../01-networking && terraform destroy
```

## License

MIT License - Feel free to use this as a template for your own projects.
