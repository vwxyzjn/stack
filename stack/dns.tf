terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_route53_zone" "costah_dev" {
  name = "costah.dev"
}
