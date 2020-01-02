// Create S3 bucket for static website hosting with cloudfront distro in front of it
module "uisite" {
  source  = "fillup/hugo-s3-cloudfront/aws"
  version = "1.0.2"

  aliases        = ["${var.ui_aliases}"]
  bucket_name    = "${var.ui_bucket_name}"
  cert_domain    = "${var.ui_cert_domain}"
  cf_default_ttl = "0"
  origin_path    = "public"
  s3_origin_id   = "s3-origin"
}

// Give Codeship user permission to deploy site to S3
data "template_file" "ui-policy" {
  template = "${file("${path.module}/codeship-s3-ui-policy.json")}"

  vars {
    bucket_name = "${var.subdomain_ui}.${var.cloudflare_domain}"
  }
}

resource "aws_iam_user_policy" "codeship-ui" {
  policy = "${data.template_file.ui-policy.rendered}"
  user   = "${data.terraform_remote_state.common.codeship_username}"
}

// Create DNS CNAME record on Cloudflare for UI
resource "cloudflare_record" "ui" {
  domain     = "${var.cloudflare_domain}"
  name       = "${var.subdomain_ui_dns_name}"
  type       = "CNAME"
  value      = "${module.uisite.cloudfront_hostname}"
  proxied    = true
  depends_on = ["module.uisite"]
}
