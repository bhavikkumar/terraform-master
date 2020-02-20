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
  tags               = var.tags
}

resource "aws_iam_role_policy" "cloudwatch_write" {
  name   = "CloudwatchLogPermissions"
  role   = aws_iam_role.cloudtrail.name
  policy = data.aws_iam_policy_document.cloudwatch_write.json
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "CloudTrail"
  retention_in_days = var.cloudwatch_log_retention_period
  kms_key_id        = var.cloudtrail_kms_key
  tags              = var.tags
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = var.cloudtrail_name
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  s3_bucket_name                = var.s3_bucket
  is_multi_region_trail         = true
  is_organization_trail         = var.is_organization_trail
  enable_log_file_validation    = true
  kms_key_id                    = var.cloudtrail_kms_key
  include_global_service_events = true
  tags                          = var.tags
}
