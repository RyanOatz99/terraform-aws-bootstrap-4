# Delegate control from root/master account to sub-account zone.
resource "aws_route53_record" "domain" {
  provider = aws.${root_name}
  zone_id  = data.aws_route53_zone.org.id
  name     = "${domain}"
  records  = aws_route53_zone.domain.name_servers
  ttl      = 30
  type     = "NS"
}

# Find the zone ID for root domain in root/master account
data "aws_route53_zone" "org" {
  provider = aws.${root_name}
  name     = "${root_domain}"
}