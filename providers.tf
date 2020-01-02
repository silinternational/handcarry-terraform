provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "cloudflare" {
  version = "~> 1.0"
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
}

