variable "region" {
  type        = string
  description = "AWS region to deploy resources in"
}

variable "base_domain" {
  type        = string
  description = "Base domain for DNS and service URLs"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM SSL certificate for HTTPS"
}

variable "cpu" {
  type        = string
  description = "CPU units for ECS Fargate task (e.g., 256, 512)"
}

variable "memory" {
  type        = string
  description = "Memory (MB) for ECS Fargate task (e.g., 512, 1024)"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs for ECS"
  default     = 7
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to run for n8n service"
  default     = 1
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
}

variable "az_count" {
  type        = number
  description = "Number of availability zones (and subnets) to use"
}

variable "subdomain" {
  type        = string
  description = "Subdomain for the n8n service (e.g., dev, staging)"

}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class (e.g., db.t3.micro)"

}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage (in GB) for RDS instance"

}