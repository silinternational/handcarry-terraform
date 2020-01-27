/*
 * Create ECR repo
 */
module "ecr" {
  source              = "github.com/silinternational/terraform-modules//aws/ecr?ref=2.7.0"
  repo_name           = "${var.app_name}-${data.terraform_remote_state.common.app_env}"
  ecsInstanceRole_arn = "${data.terraform_remote_state.common.ecsInstanceRole_arn}"
  ecsServiceRole_arn  = "${data.terraform_remote_state.common.ecsServiceRole_arn}"
  cd_user_arn         = "${data.terraform_remote_state.common.codeship_arn}"
}

/*
 * Create target group for ALB
 */
resource "aws_alb_target_group" "tg" {
  name                 = "${replace("tg-${var.app_name}-${data.terraform_remote_state.common.app_env}", "/(.{0,32})(.*)/", "$1")}"
  port                 = "3000"
  protocol             = "HTTP"
  vpc_id               = "${data.terraform_remote_state.common.vpc_id}"
  deregistration_delay = "30"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path    = "/site/status"
    matcher = "200"
  }
}

/*
 * Create listener rule for hostname routing to new target group
 */
resource "aws_alb_listener_rule" "tg" {
  listener_arn = "${data.terraform_remote_state.common.alb_https_listener_arn}"
  priority     = "719"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.tg.arn}"
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
  name              = "${var.app_name}-${data.terraform_remote_state.common.app_env}"
  retention_in_days = 14

  tags {
    app_name = "${var.app_name}"
    app_env  = "${data.terraform_remote_state.common.app_env}"
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
  source              = "github.com/silinternational/terraform-modules//aws/rds/mariadb?ref=2.7.0"
  app_name            = "${var.app_name}"
  app_env             = "${data.terraform_remote_state.common.app_env}-tf"
  engine              = "postgres"
  instance_class      = "${var.db_instance_class}"
  storage_encrypted   = "${var.db_storage_encrypted}"
  db_name             = "${var.db_database}"
  db_root_user        = "${var.db_user}"
  db_root_pass        = "${random_id.db_password.hex}"
  subnet_group_name   = "${data.terraform_remote_state.common.db_subnet_group_name}"
  availability_zone   = "${data.terraform_remote_state.common.aws_zones[0]}"
  security_groups     = ["${data.terraform_remote_state.common.vpc_default_sg_id}"]
  deletion_protection = "${var.db_deletion_protection}"
}

/*
 * Create S3 bucket and credentials to store files in the bucket for request attachments
 */
resource "aws_iam_user" "wecarry" {
  name = "${var.app_name}-${data.terraform_remote_state.common.app_env}"
}

resource "aws_iam_access_key" "attachments" {
  user = "${aws_iam_user.wecarry.name}"
}

resource "aws_iam_user_policy" "wecarry" {
  user = "${aws_iam_user.wecarry.name}"

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

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/attachment-bucket-policy.json")}"

  vars {
    bucket_name = "${var.aws_s3_bucket}"
    user_arn    = "${aws_iam_user.wecarry.arn}"
  }
}

resource "aws_s3_bucket" "attachments" {
  bucket = "${var.aws_s3_bucket}"
  acl    = "private"
  policy = "${data.template_file.bucket_policy.rendered}"

  tags = {
    Name     = "${var.aws_s3_bucket}"
    app_name = "${var.app_name}"
    app_env  = "${data.terraform_remote_state.common.app_env}"
  }
}

/*
 * Create Lambda user
 */
resource "aws_iam_user" "wecarry_lambdas" {
  name = "${var.app_name}-lambdas"
}

resource "aws_iam_access_key" "lambdas" {
  user = "${aws_iam_user.wecarry_lambdas.name}"
}

resource "aws_iam_user_policy" "wecarry_lambdas" {
  user = "${aws_iam_user.wecarry_lambdas.name}"

  policy = <<EOM
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
                "lambda:*"
            ],
            "Resource": "*"
        }
    ]
}
EOM
}

/*
 * Create task definition template
 */
data "template_file" "task_def_api" {
  template = "${file("${path.module}/task-def-api.json")}"

  vars {
    GO_ENV                    = "${var.go_env}"
    cpu                       = "${var.cpu}"
    memory                    = "${var.memory}"
    docker_image              = "${module.ecr.repo_url}"
    docker_tag                = "${var.docker_tag}"
    APP_ENV                   = "${data.terraform_remote_state.common.app_env}"
    DATABASE_URL              = "postgres://${var.db_user}:${random_id.db_password.hex}@${module.rds.address}:5432/${var.db_database}?sslmode=disable"
    UI_URL                    = "${var.ui_url}"
    HOST                      = "https://${var.subdomain_api}.${var.cloudflare_domain}"
    AWS_REGION                = "${var.aws_region}"
    AWS_S3_BUCKET             = "${var.aws_s3_bucket}"
    AWS_S3_ACCESS_KEY_ID      = "${aws_iam_access_key.attachments.id}"
    AWS_S3_SECRET_ACCESS_KEY  = "${aws_iam_access_key.attachments.secret}"
    AZURE_AD_KEY              = "${var.azure_ad_key}"
    AZURE_AD_SECRET           = "${var.azure_ad_secret}"
    AZURE_AD_TENANT           = "${var.azure_ad_tenant}"
    AUTH_CALLBACK_URL         = "${var.auth_callback_url}"
    SESSION_SECRET            = "${var.session_secret}"
    SUPPORT_EMAIL             = "${var.support_email}"
    EMAIL_FROM_ADDRESS        = "${var.email_from_address}"
    EMAIL_SERVICE             = "${var.email_service}"
    MOBILE_SERVICE            = "${var.mobile_service}"
    GOOGLE_KEY                = "${var.google_key}"
    GOOGLE_SECRET             = "${var.google_secret}"
    log_group                 = "${aws_cloudwatch_log_group.wecarry.name}"
    region                    = "${var.aws_region}"
    log_stream_prefix         = "${var.app_name}-${data.terraform_remote_state.common.app_env}"
    ROLLBAR_TOKEN             = "${var.rollbar_token}"
    SERVICE_INTEGRATION_TOKEN = "${random_id.service_integration_token.hex}"
  }
}

/*
 * Create new ecs service
 */
module "ecsapi" {
  source             = "github.com/silinternational/terraform-modules//aws/ecs/service-only?ref=2.7.0"
  cluster_id         = "${data.terraform_remote_state.common.ecs_cluster_id}"
  service_name       = "${var.app_name}-api"
  service_env        = "${data.terraform_remote_state.common.app_env}"
  container_def_json = "${data.template_file.task_def_api.rendered}"
  desired_count      = "${var.desired_count}"
  tg_arn             = "${aws_alb_target_group.tg.arn}"
  lb_container_name  = "buffalo"
  lb_container_port  = "3000"
  ecsServiceRole_arn = "${data.terraform_remote_state.common.ecsServiceRole_arn}"
}

/*
 * Create Cloudflare DNS record
 */
resource "cloudflare_record" "dns" {
  domain  = "${var.cloudflare_domain}"
  name    = "${var.subdomain_api}"
  value   = "${data.terraform_remote_state.common.alb_dns_name}"
  type    = "CNAME"
  proxied = true
}

/******
 *  Adminer service
 */
resource "aws_alb_target_group" "adminer" {
  name                 = "${replace("tg-${var.app_name}-adminer-${data.terraform_remote_state.common.app_env}", "/(.{0,32})(.*)/", "$1")}"
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = "${data.terraform_remote_state.common.vpc_id}"
  deregistration_delay = "30"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path    = "/"
    matcher = "200"
  }
}

/*
 * Create listener rule for hostname routing to new target group
 */
resource "aws_alb_listener_rule" "adminer" {
  listener_arn = "${data.terraform_remote_state.common.alb_https_listener_arn}"
  priority     = "720"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.adminer.arn}"
  }

  condition {
    host_header {
      values = ["${var.subdomain_api}-adminer.${var.cloudflare_domain}"]
    }
  }
}

/*
 * Create task definition template for Postgres Adminer
 */
data "template_file" "task_def_adminer" {
  template = "${file("${path.module}/task-def-adminer.json")}"

  vars {
    cpu                    = "128"
    memory                 = "128"
    docker_image           = "adminer"
    docker_tag             = "latest"
    ADMINER_DEFAULT_SERVER = "${module.rds.address}"
  }
}

/*
 * Create new ecs service
 */
module "ecsadminer" {
  source             = "github.com/silinternational/terraform-modules//aws/ecs/service-only?ref=2.7.0"
  cluster_id         = "${data.terraform_remote_state.common.ecs_cluster_id}"
  service_name       = "${var.app_name}-adminer"
  service_env        = "${data.terraform_remote_state.common.app_env}"
  container_def_json = "${data.template_file.task_def_adminer.rendered}"
  desired_count      = "${var.enable_adminer}"
  tg_arn             = "${aws_alb_target_group.adminer.arn}"
  lb_container_name  = "adminer"
  lb_container_port  = "8080"
  ecsServiceRole_arn = "${data.terraform_remote_state.common.ecsServiceRole_arn}"
}

/*
 * Create Cloudflare DNS record
 */
resource "cloudflare_record" "adminer" {
  count   = "${var.enable_adminer}"
  domain  = "${var.cloudflare_domain}"
  name    = "${var.subdomain_api}-adminer"
  value   = "${data.terraform_remote_state.common.alb_dns_name}"
  type    = "CNAME"
  proxied = true
}
