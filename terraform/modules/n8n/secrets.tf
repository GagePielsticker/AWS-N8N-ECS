# -----------------------------
# SECRETS MANAGER
# -----------------------------

/*
Secrets required for n8n and PostgreSQL authentication:

n8n-auth secret:
  - N8N_BASIC_AUTH_USER
  - N8N_BASIC_AUTH_PASSWORD
  - RDS_PEM (RDS CA certificate)

n8n-postgres-credential secret:
  - username
  - password

After the first Terraform deploy, you must manually populate these key-value pairs in AWS Secrets Manager. Once populated, trigger a redeploy to ensure ECS tasks receive the credentials.
*/

resource "aws_secretsmanager_secret" "n8n_basic_auth" {
  name        = "n8n-auth"
  description = "Basic auth credentials for n8n"
}

resource "aws_secretsmanager_secret" "postgres_credentials" {
  name        = "n8n-postgres-credential"
  description = "PostgreSQL credentials for n8n"
}


data "aws_secretsmanager_secret_version" "postgres_credentials" {
  secret_id = aws_secretsmanager_secret.postgres_credentials.id
}

data "aws_secretsmanager_secret_version" "n8n_basic_auth_credentials" {
  secret_id = aws_secretsmanager_secret.n8n_basic_auth.id
}

locals {
  postgres_secret = jsondecode(data.aws_secretsmanager_secret_version.postgres_credentials.secret_string)
}

locals {
  n8n_auth = jsondecode(data.aws_secretsmanager_secret_version.n8n_basic_auth_credentials.secret_string)
}