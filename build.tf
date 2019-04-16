data "aws_iam_policy_document" "dev_prod_read_access" {
  statement {
    sid    = "AllowAccountsListAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.artifact_bucket.arn}"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.master_account_id}:root",
        "arn:aws:iam::${aws_organizations_account.identity.id}:root",
        "arn:aws:iam::${aws_organizations_account.development.id}:root",
        "arn:aws:iam::${aws_organizations_account.production.id}:root"
      ]
    }
  }

  statement {
    sid    = "AllowAccountsReadAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.artifact_bucket.arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.master_account_id}:root",
        "arn:aws:iam::${aws_organizations_account.identity.id}:root",
        "arn:aws:iam::${aws_organizations_account.development.id}:root",
        "arn:aws:iam::${aws_organizations_account.production.id}:root"
      ]
    }
  }
}

data "aws_iam_policy_document" "allow_kms_key" {
  statement {
    sid    = "AllowUseOfDefaultKMSKey"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      "${aws_kms_key.default.arn}"
    ]
  }
}

data "aws_iam_policy_document" "read_artifact_bucket" {
  source_json = "${data.aws_iam_policy_document.allow_kms_key.json}"
  statement {
    sid    = "AllowListBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.artifact_bucket.arn}"
    ]
  }

  statement {
    sid    = "AllowReadBucket"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]

    resources = [
      "${aws_s3_bucket.artifact_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "rw_artifact_bucket" {
  source_json = "${data.aws_iam_policy_document.read_artifact_bucket.json}"
  statement {
    sid    = "AllowWriteBucket"
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.artifact_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "artifact.${var.domain_name}"
  acl    = "private"
  tags   = "${merge(local.common_tags, var.tags)}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.default.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
  provider = "aws.operations"
}

resource "aws_s3_bucket_policy" "dev_prod_read_access" {
  bucket   = "${aws_s3_bucket.artifact_bucket.id}"
  policy   = "${data.aws_iam_policy_document.dev_prod_read_access.json}"
  provider = "aws.operations"
}

resource "aws_iam_user" "travis_ci" {
  name     = "TravisCI"
  tags     = "${merge(local.common_tags, var.tags)}"
  provider = "aws.operations"
}

resource "aws_iam_user_policy" "travis_ci_rw_policy" {
  name     = "allow_rw_artifact_bucket"
  user     = "${aws_iam_user.travis_ci.name}"
  policy   = "${data.aws_iam_policy_document.rw_artifact_bucket.json}"
  provider = "aws.operations"
}

resource "aws_iam_access_key" "travis_ci" {
  user     = "${aws_iam_user.travis_ci.name}"
  provider = "aws.operations"
}
