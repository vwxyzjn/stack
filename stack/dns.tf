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

resource "aws_route53_record" "test" {
  zone_id = aws_route53_zone.costah_dev.zone_id
  name    = "test.costah.dev"
  type    = "A"
  ttl     = "30"
  records = ["34.92.14.177"]
}

# A records
resource "aws_route53_record" "expm" {
  zone_id = aws_route53_zone.costah_dev.zone_id
  name    = "expm.costah.dev"
  type    = "A"
  alias {
    name                   = aws_lb.wandb.dns_name
    zone_id                = aws_lb.wandb.zone_id
    evaluate_target_health = true
  }
}
