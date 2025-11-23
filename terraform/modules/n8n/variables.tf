
# -----------------------------
# VARIABLES
# -----------------------------
variable "region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where ECS service will run"
}

variable "pub_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks and ALB"
}

variable "version_update" {
  type        = string
  description = "Use this value to force a new ecs deployment"
  default     = "1"
}

variable "n8n_image" {
  type        = string
  description = "Docker image for n8n"
  default     = "n8nio/n8n:latest"
}

variable "service_name" {
  type        = string
  description = "ECS service name"
  default     = "n8n-service"
}

variable "container_port" {
  type        = number
  description = "Port on which n8n listens"
  default     = 3000
}

variable "domain_name" {
  type        = string
  description = "Domain name for n8n (must match ACM cert)"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the existing ACM certificate for the domain"
}

# Postgres variables

variable "db_name" {
  type        = string
  description = "Name of the PostgreSQL database"
  default     = "n8npostgres"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance type"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Storage size in GB"
  default     = 20
}

variable "cpu" {
  type        = string
  description = "CPU Allocation"
}

variable "memory" {
  type        = string
  description = "Memory Allocation"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 7
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to run for n8n"
  default     = 1
}