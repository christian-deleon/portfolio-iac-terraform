terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "prod"
    }
  }
}

module "backend" {
  source = "../../modules/backend"

  domain_name = var.domain_name
}

module "dns" {
  source = "../../modules/dns"

  domain_name         = var.domain_name
  s3_website_endpoint = module.backend.s3_website_endpoint
}

module "pipeline" {
  source = "../../modules/pipeline"

  github_user            = var.github_user
  github_repository_name = var.github_repository_name
  domain_name            = var.domain_name
  website_bucket_arn     = module.backend.s3_arn
  distribution_id        = module.dns.distribution_id
  distribution_arn        = module.dns.distribution_arn
}
