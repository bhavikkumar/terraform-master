data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.aws_default_region}.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_kms" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [
      "${aws_kms_key.default.arn}"
    ]
  }
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "CloudTrail"
  retention_in_days = 1
  kms_key_id        = "${var.cloudwatch_kms_key}"
  tags              = "${var.tags}"
}

resource "aws_cloudtrail" "operations-cloudtrail" {
  name                          = "cloudtrail"
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail}"
  s3_bucket_name                = "${var.s3_bucket}"
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = "${var.cloudtrail_kms_key}"
  include_global_service_events = true
  tags                          = "${var.tags}"
}
