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

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "aws_s3_bucket" {
}

variable "azure_ad_key" {
}

variable "azure_ad_secret" {
}

variable "azure_ad_tenant" {
}

variable "cloudflare_account_id" {
}

variable "cloudflare_email" {
  description = "The email associated with the Cloudflare account. Required if the API token is not provided."
  default = ""
}

variable "cloudflare_token" {
  description = "The Cloudflare API token. This is an alternative to email+api_key. If both are specified, api_token will be used over email+api_key fields."
  default = ""
}

variable "cloudflare_api_key" {
  description = "The Cloudflare API key. Required if the API token is not provided."
  default = ""
}

variable "cloudflare_domain" {
}

variable "email_from_address" {
}

variable "email_service" {
}

variable "facebook_key" {
  default = ""
}

variable "facebook_secret" {
  default = ""
}

variable "go_env" {
}

variable "google_key" {
  default = ""
}

variable "google_secret" {
  default = ""
}

variable "linked_in_key" {
  default = ""
}

variable "linked_in_secret" {
  default = ""
}

variable "microsoft_key" {
  default = ""
}

variable "microsoft_secret" {
  default = ""
}

variable "mailchimp_api_base_url" {
  default = "https://us4.api.mailchimp.com/3.0"
}

variable "mailchimp_api_key" {
}

variable "mailchimp_list_id" {
}

variable "mailchimp_username" {
}

variable "mobile_service" {
}

variable "rollbar_token" {
}

variable "session_secret" {
}

variable "subdomain_ui_dns_name" {
  description = "Used as value sent to cloudflare for dns record, separate var from subdomain_ui so that in prod we can pass @"
}

variable "twitter_key" {
  default = ""
}

variable "twitter_secret" {
  default = ""
}

variable "tf_remote_common" {
}

variable "ui_bucket_name" {
}

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

variable "ui_cert_domain" {
}

variable "ui_url" {
}

variable "ui_aliases" {
  type        = list(string)
  description = "List of domains to serve UI site on, ex: dev.wecarry.app"
}

variable "log_level" {
  description = "Level below which log messages are silenced"
}

variable "disable_tls" {
  description = "Whether or not to disable HTTPS/TLS"
  type        = string
  default     = "false"
}

