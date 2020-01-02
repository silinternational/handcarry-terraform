output "ecr_repo_url" {
  value = "${module.ecr.repo_url}"
}

output "db_password" {
  value = "${random_id.db_password.hex}"
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