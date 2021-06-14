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

resource "aws_route53_record" "expm" {
  zone_id = aws_route53_zone.costah_dev.zone_id
  name    = "expm.costah.dev"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_lb.wandb.dns_name}"]
}

resource "aws_acm_certificate" "costah_dev" {
  domain_name = aws_route53_zone.costah_dev.name
  subject_alternative_names = [
    "*.${aws_route53_zone.costah_dev.name}",
    "expm.${aws_route53_zone.costah_dev.name}",
  ]
  validation_method = "DNS"

  # Recommended by Terraform to make live-swaps smooth
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "curaihealth-certificate"
  }
}

resource "aws_route53_record" "costah_dev" {
  for_each = {
    for dvo in aws_acm_certificate.costah_dev.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.costah_dev.zone_id
}

resource "aws_acm_certificate_validation" "costah_dev" {
  certificate_arn         = aws_acm_certificate.costah_dev.arn
  validation_record_fqdns = [for record in aws_route53_record.costah_dev : record.fqdn]
}

output "name_servers" {
  value = aws_route53_zone.costah_dev.name_servers
}