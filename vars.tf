variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "handcarry"
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

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}
variable "saml_idp_sso_url" {}
variable "saml_idp_entity_id" {}
variable "saml_idp_cert_data" {}
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
  default = "admin@handcarry.app"
}

variable "alerts_email" {
  default = "admin@handcarry.app"
}

variable "alerts_email_enabled" {
  default = "true"
}

variable "db_database" {
  default = "handcarry"
}

variable "db_user" {
  default = "handcarry"
}

variable "ui_cert_domain" {}
variable "ui_url" {}

variable "ui_aliases" {
  type        = "list"
  description = "List of domains to serve UI site on, ex: dev.handcarry.app"
}