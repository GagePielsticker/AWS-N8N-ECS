# -----------------------------
# SECURITY GROUPS
# -----------------------------
resource "aws_security_group" "alb_sg" {
  name        = "n8n-alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "n8n_sg" {
  name        = "n8n-service-sg"
  description = "Allow ALB to connect to n8n tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ALB to connect"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# IAM ROLE FOR TASK EXECUTION
# -----------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "n8ntaskexecutionrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------
# IAM POLICY: ALLOW TASK TO READ SECRETS
# -----------------------------
data "aws_iam_policy_document" "ecs_task_secrets_policy" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.n8n_basic_auth.arn,
      aws_secretsmanager_secret.postgres_credentials.arn
    ]
  }
}

resource "aws_iam_policy" "ecs_task_secrets" {
  name   = "n8n-secrets-policy"
  policy = data.aws_iam_policy_document.ecs_task_secrets_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_secrets.arn
}