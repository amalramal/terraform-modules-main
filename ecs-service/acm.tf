resource "aws_acm_certificate" "cert" {
  count = var.import_acm_certificate ? 0 : 1

  domain_name       = "${var.service_name}.${var.environment}.${var.base_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_dns_validation" {
  for_each = {
    for dvo in flatten([
      for cert in aws_acm_certificate.cert : cert.domain_validation_options
      ]) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
    # Skips the domain if it doesn't contain a wildcard
    # if length(regexall("\\*\\..+", dvo.domain_name)) > 0
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "acm_dns_validation" {
  count                   = var.import_acm_certificate ? 0 : 1
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_dns_validation : record.fqdn]
}
