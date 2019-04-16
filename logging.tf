data "aws_iam_policy_document" "logging_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = [
        "logs.${var.aws_default_region}.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "log_stream_policy" {
  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:ListStreams",
      "kinesis:PutRecord"
    ]

    resources = [
      "${aws_kinesis_stream.log_stream.arn}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      "${aws_kms_key.default.arn}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "${aws_iam_role.logging_role.arn}"
    ]
  }
}

data "aws_iam_policy_document" "log_destination_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "${aws_organizations_account.identity.id}",
        "${aws_organizations_account.operations.id}",
        "${var.master_account_id}",
        "${aws_organizations_account.development.id}",
        "${aws_organizations_account.production.id}"
      ]
    }

    actions = [
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      "${aws_cloudwatch_log_destination.log_destination.arn}",
    ]
  }
}

resource "aws_kinesis_stream" "log_stream" {
  name             = "log"
  shard_count      = 1
  retention_period = 24
  encryption_type  = "KMS"
  kms_key_id       = "${aws_kms_key.default.arn}"
  tags             = "${merge(local.common_tags, var.tags)}"
  provider         = "aws.operations"
}

resource "aws_iam_role" "logging_role" {
  name               = "log_desination_role"
  description        = "Used by Cloudwatch logs to put items on the log stream"
  assume_role_policy = "${data.aws_iam_policy_document.logging_assume_role.json}"
  tags               = "${merge(local.common_tags, var.tags)}"
  provider           = "aws.operations"
}

resource "aws_iam_role_policy" "put_kinesis_events" {
  name       = "cloudwatch-log-permissions"
  role       = "${aws_iam_role.logging_role.name}"
  policy     = "${data.aws_iam_policy_document.log_stream_policy.json}"
  provider   = "aws.operations"
}

resource "aws_cloudwatch_log_destination" "log_destination" {
  name       = "log"
  role_arn   = "${aws_iam_role.logging_role.arn}"
  target_arn = "${aws_kinesis_stream.log_stream.arn}"
  provider   = "aws.operations"
}

resource "aws_cloudwatch_log_destination_policy" "log_destination_policy" {
  destination_name = "${aws_cloudwatch_log_destination.log_destination.name}"
  access_policy    = "${data.aws_iam_policy_document.log_destination_policy.json}"
  provider   = "aws.operations"
}

module "retention-period-master" {
  source               = "./modules/cloudwatch-retention-period-lambda"
  kms_key_arn          = "${aws_kms_key.default.arn}"
  log_retention_period = 14
  s3_bucket            = "artifact.bhavik.io"
  s3_folder            = "lambda"
  tags                 = "${merge(local.common_tags, var.tags)}"
  app_version          = "1.0.2"

  providers = {
    aws = "aws.master"
  }
}

module "retention-period-ops" {
  source               = "./modules/cloudwatch-retention-period-lambda"
  kms_key_arn          = "${aws_kms_key.default.arn}"
  log_retention_period = 14
  s3_bucket            = "artifact.bhavik.io"
  s3_folder            = "lambda"
  tags                 = "${merge(local.common_tags, var.tags)}"
  app_version          = "1.0.2"

  providers = {
    aws = "aws.operations"
  }
}

module "retention-period-identity" {
  source               = "./modules/cloudwatch-retention-period-lambda"
  kms_key_arn          = "${aws_kms_key.default.arn}"
  log_retention_period = 14
  s3_bucket            = "artifact.bhavik.io"
  s3_folder            = "lambda"
  tags                 = "${merge(local.common_tags, var.tags)}"
  app_version          = "1.0.2"

  providers = {
    aws = "aws.identity"
  }
}

module "retention-period-development" {
  source               = "./modules/cloudwatch-retention-period-lambda"
  kms_key_arn          = "${aws_kms_key.default.arn}"
  log_retention_period = 14
  s3_bucket            = "artifact.bhavik.io"
  s3_folder            = "lambda"
  tags                 = "${merge(local.common_tags, var.tags)}"
  app_version          = "1.0.2"

  providers = {
    aws = "aws.development"
  }
}

module "retention-period-production" {
  source               = "./modules/cloudwatch-retention-period-lambda"
  kms_key_arn          = "${aws_kms_key.default.arn}"
  log_retention_period = 14
  s3_bucket            = "artifact.bhavik.io"
  s3_folder            = "lambda"
  tags                 = "${merge(local.common_tags, var.tags)}"
  app_version          = "1.0.2"

  providers = {
    aws = "aws.production"
  }
}
