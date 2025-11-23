terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
  backend "s3" {
    bucket       = "<<S3_BUCKET_NAME_HERE>>"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      project = "n8n"
    }
  }
}
