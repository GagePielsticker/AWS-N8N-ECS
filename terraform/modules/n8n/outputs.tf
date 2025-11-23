# -----------------------------
# OUTPUTS
# -----------------------------
output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.n8n_alb.dns_name
}

output "alb_https_url" {
  description = "HTTPS URL of the n8n service"
  value       = "https://${var.domain_name}"
}

output "postgres_endpoint" {
  description = "PostgreSQL database endpoint"
  value       = aws_db_instance.n8n_postgres.address
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.n8n_cluster.name
}

output "n8n_service_name" {
  value = aws_ecs_service.n8n_service.name
}

output "security_group_ids" {
  value = {
    alb      = aws_security_group.alb_sg.id
    ecs      = aws_security_group.n8n_sg.id
    postgres = aws_security_group.postgres_sg.id
  }
}

output "postgres_secret_arn" {
  description = "ARN of the PostgreSQL credentials secret"
  value       = aws_secretsmanager_secret.postgres_credentials.arn
}
