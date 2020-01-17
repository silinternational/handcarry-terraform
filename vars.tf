variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "wecarry"
}

variable "memory" {
  default = "128"
}

variable "cpu" {
  default = "200"
}

variable "desired_count" {
  default = 2
}

variable "enable_adminer" {
  default     = 0
  description = "1 = enable adminer, 0 = disable adminer"
}

variable "auth_callback_url" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_s3_bucket" {}
variable "azure_ad_key" {}
variable "azure_ad_secret" {}
variable "azure_ad_tenant" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}
variable "email_from_address" {}
variable "email_service" {}
variable "go_env" {}
variable "google_key" {}
variable "google_secret" {}
variable "mobile_service" {}
variable "rollbar_token" {}
variable "session_secret" {}
variable "subdomain_ui_dns_name" {
  description = "Used as value sent to cloudflare for dns record, separate var from subdomain_ui so that in prod we can pass @"
}
variable "tf_remote_common" {}
variable "ui_bucket_name" {}

variable "subdomain_api" {
  default = "api"
}

variable "subdomain_ui" {
  default = "my"
}

variable "docker_tag" {
  default = "latest"
}

variable "admin_email" {
  default = "support@wecarry.app"
}

variable "alerts_email" {
  default = "support@wecarry.app"
}

variable "support_email" {
  default = "support@wecarry.app"
}

variable "alerts_email_enabled" {
  default = "true"
}

variable "db_database" {
  default = "wecarry"
}

variable "db_user" {
  default = "wecarry"
}

variable "db_instance_class" {
  default = "db.t2.micro"
}

variable "db_storage_encrypted" {
  default = "false"
}

variable "db_deletion_protection" {
  default = "false"
}

variable "ui_cert_domain" {}
variable "ui_url" {}

variable "ui_aliases" {
  type        = "list"
  description = "List of domains to serve UI site on, ex: dev.wecarry.app"
}