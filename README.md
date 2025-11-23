# AWS N8N ECS Terraform Deployment

This repository contains Terraform code to deploy the n8n automation platform on AWS using ECS (Elastic Container Service), with supporting infrastructure for networking, security, and DNS.

## Features
- **VPC Module**: Provisions a dedicated Virtual Private Cloud with public subnets and internet gateway.
- **n8n Module**: Deploys n8n as a scalable ECS Fargate service behind an Application Load Balancer (ALB), with HTTPS support via ACM certificates.
- **PostgreSQL Database**: Manages a secure RDS instance for n8n data storage.
- **Secrets Management**: Uses AWS Secrets Manager for sensitive credentials.
- **Custom Domain Support**: Integrates with Route 53 and ACM for custom domain and SSL.

## Structure
- `terraform/environments/dev/` – Environment-specific configuration and variables.
- `terraform/modules/vpc/` – VPC and networking resources.
- `terraform/modules/n8n/` – ECS, ALB, and n8n service resources.
- `terraform/modules/r53/` – (Optional) Route 53 and ACM resources for DNS and SSL.

## Usage
1. Configure your variables in `terraform/environments/dev/input.tfvars` (set domain, subdomain, etc.).
2. Run `terraform init` and `terraform apply` in the environment APdirectory to provision resources.
3. Reference secret management below to assign rds user/password etc.
4. Re-deploy.
5. Access n8n via the custom domain once deployment is complete.

## Prerequisites
- AWS account and credentials
- Terraform CLI

## Notes
- Ensure ACM certificates are issued in the same region as your ALB.
- DNS records and SSL setup require domain ownership and validation.

## Secrets Management
This deployment uses AWS Secrets Manager for sensitive credentials. After the first Terraform deploy, you must manually populate the following secrets in AWS Secrets Manager:

- **n8n-auth**
  - `N8N_BASIC_AUTH_USER`: Username for n8n basic auth
  - `N8N_BASIC_AUTH_PASSWORD`: Password for n8n basic auth
  - `RDS_PEM`: RDS CA certificate (for database SSL)
- **n8n-postgres-credential**
  - `username`: PostgreSQL username
  - `password`: PostgreSQL password

After populating these secrets, trigger a redeploy so ECS tasks can access the credentials.

---
For more details, see comments in each module and environment file.
