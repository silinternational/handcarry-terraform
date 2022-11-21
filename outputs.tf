output "ecr_repo_url" {
  value = module.ecr.repo_url
}

output "db_password" {
  value = random_id.db_password.hex
}

output "ui_bucket" {
  value = cloudflare_record.ui.hostname
}

output "ui_url" {
  value = "https://${cloudflare_record.ui.hostname}"
}

output "api_url" {
  value = "https://${cloudflare_record.dns.hostname}"
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


/*
 * Backup outputs are just here for convenience
 */

output "bkup_key_arn" {
  value = var.enable_db_backup ? module.backup_rds[0].bkup_key_arn : "backup disabled"
}

output "bkup_key_id" {
  value = var.enable_db_backup ? module.backup_rds[0].bkup_key_id : "to enable backup, set enable_db_backup to true"
}

output "bkup_vault_arn" {
  value = var.enable_db_backup ? module.backup_rds[0].bkup_vault_arn : ""
}

output "bkup_cron_schedule" {
  value = var.enable_db_backup ? var.backup_cron_schedule : ""
}

output "backup_notification_events" {
  value = var.enable_db_backup ? join(", ", var.backup_notification_events) : ""
}
