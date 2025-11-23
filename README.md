# AWS N8N ECS Terraform Deployment

This repository contains Terraform code to deploy the n8n automation platform on AWS using ECS (Elastic Container Service), with supporting infrastructure for networking, security, and DNS.

## Usage
0. Configure s3 bucket in `terraform/environments/dev/providers.tf`.
1. Configure your variables in `terraform/environments/dev/input.tfvars` (set domain, subdomain, etc.).
2. Run `terraform init` and `terraform apply` in the environment directory to provision resources.
3. Reference secret management below to assign rds user/password etc.
4. Re-deploy.
5. Access n8n via the custom domain once deployment is complete.

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
