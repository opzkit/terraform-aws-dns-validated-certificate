variable "zone" {
  type        = object({ name : string, zone_id : string })
  description = "The Route53 zone to use for domain and validation"
}
