# PostgreSQL SG
resource "aws_security_group" "postgres_sg" {
  name        = "n8n-postgres-sg"
  description = "Allow ECS tasks to connect to PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ECS tasks to connect to PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.n8n_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# POSTGRES DATABASE
# -----------------------------
resource "aws_db_subnet_group" "n8n_db_subnet_group" {
  name        = "n8n-db-subnet-group"
  subnet_ids  = var.pub_subnet_ids
  description = "Subnet group for n8n PostgreSQL database"
}

resource "aws_db_instance" "n8n_postgres" {
  identifier             = "n8n-postgres-dbs"
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = local.postgres_secret.username
  password               = local.postgres_secret.password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.n8n_db_subnet_group.name
  publicly_accessible    = false
  storage_encrypted      = true
}
