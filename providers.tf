provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "cloudflare" {
  email      = var.cloudflare_email
  api_key    = var.cloudflare_api_key
  api_token  = var.cloudflare_token
  account_id = var.cloudflare_account_id
}
