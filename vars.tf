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
variable "aws_s3_access_key_id" {}
variable "aws_s3_secret_access_key" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}
variable "email_from_address" {}
variable "email_service" {}
variable "google_key" {}
variable "google_secret" {}
variable "saml_idp_sso_url" {}
variable "saml_idp_entity_id" {}
variable "saml_idp_cert_data" {}
variable "sendgrid_api_key" {}
variable "session_secret" {}
variable "tf_remote_common" {}


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

variable "alerts_email_enabled" {
  default = "true"
}

variable "db_database" {
  default = "wecarry"
}

variable "db_user" {
  default = "wecarry"
}

variable "ui_cert_domain" {}
variable "ui_url" {}

variable "ui_aliases" {
  type        = "list"
  description = "List of domains to serve UI site on, ex: dev.wecarry.app"
}