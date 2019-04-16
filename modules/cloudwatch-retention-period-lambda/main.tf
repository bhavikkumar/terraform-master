data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_write_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.lambda.arn}"
    ]
  }
}

data "aws_iam_policy_document" "retention_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "RetentionPeriodLambda"
  description        = "Used by CloudWatch Retention Period Lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  tags               = "${var.tags}"
}

resource "aws_iam_role_policy" "lambda_write_logs" {
  name   = "CloudwatchLogWritePermissions"
  role   = "${aws_iam_role.lambda.name}"
  policy = "${data.aws_iam_policy_document.lambda_write_logs.json}"
}

resource "aws_iam_role_policy" "lambda_retention_policy" {
  name   = "AllowPutRetentionPolicy"
  role   = "${aws_iam_role.lambda.name}"
  policy = "${data.aws_iam_policy_document.retention_policy.json}"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = "${var.log_retention_period}"
  kms_key_id        = "${var.kms_key_arn}"
  tags              = "${var.tags}"
}

resource "aws_lambda_function" "lambda" {
  function_name = "CloudWatchLogRetentionPeriod"
  description   = "Sets the cloudwatch log retention period to ${var.log_retention_period}"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "main"
  runtime       = "go1.x"
  memory_size   = 128
  kms_key_arn   = "${var.kms_key_arn}"
  s3_bucket     = "${var.s3_bucket}"
  s3_key        = "${var.s3_folder}/cloudwatch-log-retention${var.app_version}.zip"

  environment {
    variables = {
      RETENTION_PERIOD = "${var.log_retention_period}"
    }
  }
  tags = "${var.tags}"
}

resource "aws_cloudwatch_event_rule" "retention_period" {
  name        = "LogRetentionPeriodModifications"
  description = "Captures when log groups are created or the retention periods are modified"
  tags        = "${var.tags}"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.logs"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "logs.amazonaws.com"
    ],
    "eventName": [
      "CreateLogGroup",
      "PutRetentionPolicy",
      "DeleteRetentionPolicy"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "retetion_period_lambda" {
  rule      = "${aws_cloudwatch_event_rule.retention_period.name}"
  arn       = "${aws_lambda_function.lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowRetentionPeriodLambdaExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.retention_period.arn}"
}
