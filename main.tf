resource "aws_acm_certificate" "cert" {
  domain_name               = var.zone.name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.zone.name}"]
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.zone.name} wildcard certificate"
  }
}

resource "aws_route53_record" "validation" {
  depends_on = [aws_acm_certificate.cert]
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records = [
    each.value.record
  ]
  ttl     = 60
  type    = each.value.type
  zone_id = var.zone.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
