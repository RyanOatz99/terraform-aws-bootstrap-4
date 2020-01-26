resource "aws_route53_zone" "domain" {
  provider = aws.${provider}
  name     = "${domain}"
}