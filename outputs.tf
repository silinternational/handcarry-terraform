output "ecr_repo_url" {
  value = module.ecr.repo_url
}

output "db_password" {
  value = random_id.db_password.hex
}

output "ui_bucket" {
  value = "${var.subdomain_ui}.${var.cloudflare_domain}"
}

output "ui_url" {
  value = "https://${var.subdomain_ui}.${var.cloudflare_domain}"
}

output "api_url" {
  value = "https://${var.subdomain_api}.${var.cloudflare_domain}"
}

output "serverless-access-key-id" {
  value = module.serverless-user.aws_access_key_id
}
output "serverless-secret-access-key" {
  value = nonsensitive(module.serverless-user.aws_secret_access_key)
}

output "service_integration_token" {
  value = random_id.service_integration_token.hex
}
