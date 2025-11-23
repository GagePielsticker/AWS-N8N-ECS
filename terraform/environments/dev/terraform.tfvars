region = "us-east-1"

#DNS Stuff
base_domain         = "" // e.g. example.com   Requires r53 setup
subdomain           = "" // e.g. n8n              Requires r53 setup
acm_certificate_arn = "" // ACM cert *.example.com

#ECS Config
cpu    = "256"
memory = "512"

# RDS cost-optimized
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20

# Log retention and ECS desired count
log_retention_days = 7
desired_count      = 1


cidr_block = "10.0.0.0/16"
vpc_name   = "dev-n8n-vpc"
az_count   = 2