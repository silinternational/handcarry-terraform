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
variable "tf_remote_common" {}
variable "logentries_account_key" {}

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

variable "saml_contact_email" {
  default = "gtis_appsdev_alerts@groups.sil.org"
}

variable "saml_contact_name" {
  default = "GTIS Application Development"
}

variable "saml_entity_id" {
  default = "doorman"
}

variable "saml_org_name" {
  default = "Insite"
}

variable "saml_org_url" {
  default = "https://www.insitehome.org"
}

variable "enable_phpmyadmin" {
  default = 0
}

variable "api_base_url" {}
variable "saml_application_baseurl" {}
variable "saml_baseurlpath" {}
variable "saml_cert_data" {}
variable "saml_idp" {}
variable "saml_slo_url" {}
variable "saml_sso_url" {}
variable "ui_cert_domain" {}
variable "ui_url" {}
variable "ui_url_logged_out" {}

variable "ui_aliases" {
  type        = "list"
  description = "List of domains to serve UI site on, ex: dev.handcarry.app"
}