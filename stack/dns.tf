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

resource "aws_route53_zone" "costahuang_me" {
  name = "costahuang.me"
}

resource "aws_route53_record" "tt" {
  zone_id = aws_route53_zone.costah_dev.zone_id
  name    = "tt.costah.dev"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_lb.wandb.dns_name}"]
}

resource "aws_route53_record" "tt1" {
  zone_id = aws_route53_zone.costahuang_me.zone_id
  name    = "tt.costahuang.me"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_lb.wandb.dns_name}"]
}


resource "aws_acm_certificate" "costah_dev" {
  domain_name       = "costah.dev"
  validation_method = "DNS"
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
