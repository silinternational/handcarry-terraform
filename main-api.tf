/*
 * Create ECR repo
 */
module "ecr" {
  source              = "github.com/silinternational/terraform-modules//aws/ecr?ref=3.6.2"
  repo_name           = local.app_name_and_env
  ecsInstanceRole_arn = data.terraform_remote_state.common.outputs.ecsInstanceRole_arn
  ecsServiceRole_arn  = data.terraform_remote_state.common.outputs.ecsServiceRole_arn
  cd_user_arn         = data.terraform_remote_state.common.outputs.codeship_arn
}

/*
 * Create target group for ALB
 */
resource "aws_alb_target_group" "tg" {
  name = replace(
    "tg-${local.app_name_and_env}",
    "/(.{0,32})(.*)/",
    "$1",
  )
  port                 = "3000"
  protocol             = var.disable_tls == "true" ? "HTTP" : "HTTPS"
  vpc_id               = data.terraform_remote_state.common.outputs.vpc_id
  deregistration_delay = "30"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path     = "/site/status"
    matcher  = "200"
    protocol = var.disable_tls == "true" ? "HTTP" : "HTTPS"
  }
}

/*
 * Create listener rule for hostname routing to new target group
 */
resource "aws_alb_listener_rule" "tg" {
  listener_arn = data.terraform_remote_state.common.outputs.alb_https_listener_arn
  priority     = "719"

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["${var.subdomain_api}.${var.cloudflare_domain}"]
    }
  }
}

/*
 * Create cloudwatch log group for app logs
 */
resource "aws_cloudwatch_log_group" "wecarry" {
  name              = local.app_name_and_env
  retention_in_days = 14

  tags = {
    app_name = var.app_name
    app_env  = local.app_env
  }
}

/*
 * Create required passwords
 */
resource "random_id" "db_password" {
  byte_length = 16
}

resource "random_id" "service_integration_token" {
  byte_length = 16
}

/*
 * Create new rds instance
 */
module "rds" {
  source              = "github.com/silinternational/terraform-modules//aws/rds/mariadb?ref=3.6.2"
  app_name            = var.app_name
  app_env             = "${local.app_env}-tf"
  engine              = "postgres"
  engine_version      = "12.7"
  instance_class      = var.db_instance_class
  storage_encrypted   = var.db_storage_encrypted
  db_name             = var.db_database
  db_root_user        = var.db_user
  db_root_pass        = random_id.db_password.hex
  subnet_group_name   = data.terraform_remote_state.common.outputs.db_subnet_group_name
  availability_zone   = data.terraform_remote_state.common.outputs.aws_zones[0]
  security_groups     = [data.terraform_remote_state.common.outputs.vpc_default_sg_id]
  deletion_protection = var.db_deletion_protection
}

/*
 * Create user to interact with S3 and SES
 */
resource "aws_iam_user" "wecarry" {
  name = local.app_name_and_env
}

resource "aws_iam_access_key" "attachments" {
  user = aws_iam_user.wecarry.name
}

resource "aws_iam_user_policy" "wecarry" {
  user = aws_iam_user.wecarry.name

  policy = <<EOM
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SendEmail",
      "Effect": "Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*"
    }
  ]
}
EOM

}

locals {
  bucket_policy = templatefile("${path.module}/attachment-bucket-policy.json",
    {
      bucket_name = var.aws_s3_bucket
      user_arn    = aws_iam_user.wecarry.arn
    }
  )
}

resource "aws_s3_bucket" "attachments" {
  bucket = var.aws_s3_bucket
  acl    = "private"
  policy = local.bucket_policy

  tags = {
    Name     = var.aws_s3_bucket
    app_name = var.app_name
    app_env  = local.app_env
  }
}


/*
 * Create IAM user for Serverless framework to use to deploy the lambda function
 */
module "serverless-user" {
  source  = "silinternational/serverless-user/aws"
  version = "0.1.0"

  app_name   = "wecarry-${local.app_env}"
  aws_region = var.aws_region
}

/*
 * Create task definition template
 */
locals {
  task_def = templatefile("${path.module}/task-def-api.json",
    {
      GO_ENV                    = var.go_env
      cpu                       = var.cpu
      memory                    = var.memory
      docker_image              = module.ecr.repo_url
      docker_tag                = var.docker_tag
      APP_ENV                   = local.app_env
      DATABASE_URL              = "postgres://${var.db_user}:${random_id.db_password.hex}@${module.rds.address}:5432/${var.db_database}?sslmode=disable"
      UI_URL                    = var.ui_url
      HOST                      = "https://${var.subdomain_api}.${var.cloudflare_domain}"
      AWS_DEFAULT_REGION        = var.aws_region
      AWS_S3_BUCKET             = var.aws_s3_bucket
      AWS_ACCESS_KEY_ID         = aws_iam_access_key.attachments.id
      AWS_SECRET_ACCESS_KEY     = aws_iam_access_key.attachments.secret
      AZURE_AD_KEY              = var.azure_ad_key
      AZURE_AD_SECRET           = var.azure_ad_secret
      AZURE_AD_TENANT           = var.azure_ad_tenant
      SESSION_SECRET            = var.session_secret
      SUPPORT_EMAIL             = var.support_email
      EMAIL_FROM_ADDRESS        = var.email_from_address
      EMAIL_SERVICE             = var.email_service
      MAILCHIMP_API_BASE_URL    = var.mailchimp_api_base_url
      MAILCHIMP_API_KEY         = var.mailchimp_api_key
      MAILCHIMP_LIST_ID         = var.mailchimp_list_id
      MAILCHIMP_USERNAME        = var.mailchimp_username
      MOBILE_SERVICE            = var.mobile_service
      FACEBOOK_KEY              = var.facebook_key
      FACEBOOK_SECRET           = var.facebook_secret
      GOOGLE_KEY                = var.google_key
      GOOGLE_SECRET             = var.google_secret
      LINKED_IN_KEY             = var.linked_in_key
      LINKED_IN_SECRET          = var.linked_in_secret
      MICROSOFT_KEY             = var.microsoft_key
      MICROSOFT_SECRET          = var.microsoft_secret
      TWITTER_KEY               = var.twitter_key
      TWITTER_SECRET            = var.twitter_secret
      log_group                 = aws_cloudwatch_log_group.wecarry.name
      region                    = var.aws_region
      log_stream_prefix         = local.app_name_and_env
      ROLLBAR_TOKEN             = var.rollbar_token
      SERVICE_INTEGRATION_TOKEN = random_id.service_integration_token.hex
      LOG_LEVEL                 = var.log_level
      DISABLE_TLS               = var.disable_tls
      REDIS_INSTANCE_HOST_PORT  = "${module.redis.cluster_address}:6379"
    }
  )
}

/*
 * Create new ecs service
 */
module "ecsapi" {
  source             = "github.com/silinternational/terraform-modules//aws/ecs/service-only?ref=3.6.2"
  cluster_id         = data.terraform_remote_state.common.outputs.ecs_cluster_id
  service_name       = "${var.app_name}-api"
  service_env        = local.app_env
  container_def_json = local.task_def
  desired_count      = var.desired_count
  tg_arn             = aws_alb_target_group.tg.arn
  lb_container_name  = "buffalo"
  lb_container_port  = "3000"
  ecsServiceRole_arn = data.terraform_remote_state.common.outputs.ecsServiceRole_arn
}

/*
 * Create Cloudflare DNS record
 */
resource "cloudflare_record" "dns" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.subdomain_api
  value   = data.terraform_remote_state.common.outputs.alb_dns_name
  type    = "CNAME"
  proxied = true
}

data "cloudflare_zones" "domain" {
  filter {
    name        = var.cloudflare_domain
    lookup_type = "exact"
    status      = "active"
  }
}

module "adminer" {
  source                 = "silinternational/adminer/aws"
  version                = "1.0.0"
  adminer_default_server = module.rds.address
  adminer_design         = var.adminer_design
  adminer_plugins        = var.adminer_plugins
  app_name               = var.app_name
  app_env                = local.app_env
  cpu                    = 128
  vpc_id                 = data.terraform_remote_state.common.outputs.vpc_id
  alb_https_listener_arn = data.terraform_remote_state.common.outputs.alb_https_listener_arn
  alb_listener_priority  = 720
  subdomain              = "${var.subdomain_api}-adminer"
  cloudflare_domain      = var.cloudflare_domain
  ecs_cluster_id         = data.terraform_remote_state.common.outputs.ecs_cluster_id
  ecsServiceRole_arn     = data.terraform_remote_state.common.outputs.ecsServiceRole_arn
  alb_dns_name           = data.terraform_remote_state.common.outputs.alb_dns_name
  enable                 = var.enable_adminer
}

module "redis" {
  source             = "github.com/silinternational/terraform-modules//aws/elasticache/redis?ref=3.6.2"
  cluster_id         = "${local.app_name_and_env}-redis"
  security_group_ids = [data.terraform_remote_state.common.outputs.vpc_default_sg_id]
  subnet_group_name  = "${local.app_name_and_env}-redis"
  subnet_ids         = data.terraform_remote_state.common.outputs.private_subnet_ids
  availability_zones = data.terraform_remote_state.common.outputs.aws_zones
  app_name           = var.app_name
  app_env            = local.app_env
}

locals {
  app_env          = data.terraform_remote_state.common.outputs.app_env
  app_name_and_env = "${var.app_name}-${data.terraform_remote_state.common.outputs.app_env}"
}
