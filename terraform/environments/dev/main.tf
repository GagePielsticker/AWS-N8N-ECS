module "vpc" {
  source     = "../../modules/vpc"
  name       = var.vpc_name
  cidr_block = var.cidr_block
  az_count   = var.az_count
}

module "n8n" {
  source = "../../modules/n8n"
  region = var.region

  vpc_id         = module.vpc.vpc_id
  pub_subnet_ids = module.vpc.public_subnet_ids

  domain_name         = "${var.subdomain}.${var.base_domain}" //Domain to pass to n8n module
  acm_certificate_arn = var.acm_certificate_arn               //Certificate for the custom domain SSL

  cpu    = var.cpu
  memory = var.memory

  desired_count      = var.desired_count
  log_retention_days = var.log_retention_days
}
