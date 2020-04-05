module "cloudtrail-s3-kms" {
  source                = "./modules/cloudtrail-s3-kms"
  aws_region            = var.aws_default_region
  cloudtrail_account_id = var.master_account_id
  domain_name           = var.domain_name
  operations_account_id = aws_organizations_account.operations.id
  tags                  = merge(local.common_tags, var.tags)

  providers = {
    aws = aws.operations
  }
}

data "aws_iam_policy_document" "cloudwatch_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_write" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.cloudtrail.arn
    ]
  }
}

resource "aws_iam_role" "cloudtrail" {
  name               = "CloudTrail"
  description        = "Used by CloudTrail to write logs to cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume.json
  tags               = merge(local.common_tags, var.tags)
  provider           = aws.master
}

resource "aws_iam_role_policy" "cloudwatch_write" {
  name     = "CloudwatchLogPermissions"
  role     = aws_iam_role.cloudtrail.name
  policy   = data.aws_iam_policy_document.cloudwatch_write.json
  provider = aws.master
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "CloudTrail"
  retention_in_days = 14
  kms_key_id        = module.cloudtrail-s3-kms.kms_key_arn
  tags              = merge(local.common_tags, var.tags)
  provider          = aws.master
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "CloudTrail"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  s3_bucket_name                = module.cloudtrail-s3-kms.s3_bucket
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = module.cloudtrail-s3-kms.kms_key_arn
  include_global_service_events = true
  tags                          = merge(local.common_tags, var.tags)
  provider                      = aws.master
}

resource "aws_cloudwatch_log_subscription_filter" "cloudtrail_log_filter" {
  name            = "cloudtrail_log_filter"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = ""
  destination_arn = aws_cloudwatch_log_destination.log_destination.arn
  distribution    = "ByLogStream"
  provider        = aws.master
}

