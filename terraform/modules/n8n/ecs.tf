# -----------------------------
# ECS CLUSTER
# -----------------------------
resource "aws_ecs_cluster" "n8n_cluster" {
  name = "n8n-cluster"
}

# -----------------------------
# CLOUDWATCH LOG GROUP
# -----------------------------
resource "aws_cloudwatch_log_group" "n8n_logs" {
  name              = "/ecs/n8n"
  retention_in_days = var.log_retention_days
}

# -----------------------------
# LOAD BALANCER
# -----------------------------
resource "aws_lb" "n8n_alb" {
  name               = "n8n-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.pub_subnet_ids
}

resource "aws_lb_target_group" "n8n_tg" {
  name        = "n8n-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "n8n_listener" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n_tg.arn
  }
}

resource "aws_lb_listener" "n8n_https_listener" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n_tg.arn
  }
}

# Redirect HTTP → HTTPS
resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = aws_lb_listener.n8n_listener.arn
  priority     = 1

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

# -----------------------------
# ECS TASK DEFINITION
# -----------------------------
resource "aws_ecs_task_definition" "n8n_task" {
  family                   = "n8n-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "n8n"
      image     = var.n8n_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      environment = [
        { name = "N8N_BASIC_AUTH_ACTIVE", value = "true" },
        { name = "N8N_PORT", value = tostring(var.container_port) },
        { name = "DB_TYPE", value = "postgresdb" },
        { name = "FORCE_NEW_UPDATE_VALUE", value = var.version_update },
        { name = "DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED", value = "0" }, // DB Cert Error Fix (TEMP)
        { name = "DB_POSTGRESDB_DATABASE", value = var.db_name },
        { name = "DB_POSTGRESDB_HOST", value = aws_db_instance.n8n_postgres.address },
        { name = "DB_POSTGRESDB_PORT", value = "5432" },
        { name = "DB_POSTGRESDB_SSL_ENABLED", value = "true" },
        { name = "WEBHOOK_URL", value = "https://${var.domain_name}/" },
        { name = "N8N_HOST", value = var.domain_name },
        { name = "N8N_PROTOCOL", value = "https" }
      ]
      secrets = [
        {
          name      = "N8N_BASIC_AUTH_USER"
          valueFrom = "${aws_secretsmanager_secret.n8n_basic_auth.arn}:N8N_BASIC_AUTH_USER::"
        },
        {
          name      = "N8N_BASIC_AUTH_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.n8n_basic_auth.arn}:N8N_BASIC_AUTH_PASSWORD::"
        },
        {
          name      = "DB_POSTGRESDB_USER"
          valueFrom = "${aws_secretsmanager_secret.postgres_credentials.arn}:username::"
        },
        {
          name      = "DB_POSTGRESDB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.postgres_credentials.arn}:password::"
        },
        {
          name      = "RDS_CA_CERT"
          valueFrom = "${aws_secretsmanager_secret.n8n_basic_auth.arn}:RDS_PEM::"
        }
      ]

      # Write the CA cert secret to /tmp/global-bundle.pem before starting n8n
      entryPoint = [
        "sh", "-c",
        <<EOT
echo "$RDS_CA_CERT" > /tmp/global-bundle.pem && \
export NODE_EXTRA_CA_CERTS=/tmp/global-bundle.pem && \
export DB_POSTGRESDB_SSL_CA_FILE=/tmp/global-bundle.pem && \
exec n8n
EOT
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.n8n_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "n8n"
        }
      }
    }
  ])
}

# -----------------------------
# ECS SERVICE
# -----------------------------
resource "aws_ecs_service" "n8n_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.n8n_cluster.id
  task_definition = aws_ecs_task_definition.n8n_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.pub_subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.n8n_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.n8n_tg.arn
    container_name   = "n8n"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.n8n_listener,
    aws_lb_listener.n8n_https_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]
}