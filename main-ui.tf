// Create S3 bucket for static website hosting with cloudfront distro in front of it
module "uisite" {
  source  = "fillup/hugo-s3-cloudfront/aws"
  version = "4.1.0"

  aliases             = var.ui_aliases
  bucket_name         = var.ui_bucket_name
  cert_domain         = var.ui_cert_domain
  cf_default_ttl      = "0"
  cf_min_ttl          = "0"
  cf_max_ttl          = "0"
  origin_path         = "/public"
  error_document      = "index.html"
  index_document      = "index.html"
  s3_origin_id        = "s3-origin"
  deployment_user_arn = data.terraform_remote_state.common.outputs.codeship_arn

  default_root_object = null
  custom_error_response = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    },
  ]
}

// Create DNS CNAME record on Cloudflare for UI
resource "cloudflare_record" "ui" {
  zone_id    = data.cloudflare_zones.domain.zones[0].id
  name       = var.subdomain_ui_dns_name
  type       = "CNAME"
  value      = module.uisite.cloudfront_hostname
  proxied    = true
  depends_on = [module.uisite]
}
