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
