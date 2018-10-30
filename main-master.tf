provider "aws" {
  region = "${var.aws_default_region}"
  version = "~> 1.38"
  skip_credentials_validation = true
}

provider "aws" {
  alias = "master"
  profile = "terraform-master"
  region = "${var.aws_default_region}"
  allowed_account_ids = ["${var.master_account_id}"]
}

terraform {
 backend "s3" {
   key     = "common/master"
   encrypt = true
 }
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = true
  max_password_age               = 0
  provider = "aws.master"
}

resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
  provider = "aws.master"
}

// This is just here because its a suspended account from earlier testing of terraform
resource "aws_organizations_account" "deleted_operations" {
  name  = "${var.prefix}-operations"
  //email = "580a5d93-f5c5-46e5-84f0-140c4bb8bcaf@bhavik.io"
  email = "vohimoket-0833@yopmail.com"
  provider = "aws.master"
}

// This is the actual operations account to be used
resource "aws_organizations_account" "operations" {
  name  = "demo-operations"
  email = "580a5d93-f5c5-46e5-84f0-140c4bb8bcaf@${var.domain_name}"
  provider = "aws.master"
}

// Set human readable alias for the account
resource "aws_iam_account_alias" "master" {
  account_alias = "${var.prefix}-master"
  provider = "aws.master"
}

// Create IAM groups and roles in the master account
resource "aws_iam_group" "admin" {
  name = "Admin"
  provider = "aws.master"
}

resource "aws_iam_group_policy" "mfa_admin" {
  name = "mfa-policy"
  group  = "${aws_iam_group.admin.id}"
  policy = "${data.aws_iam_policy_document.mfa.json}"
  provider = "aws.master"
}

resource "aws_iam_group_policy" "admin_assume_role" {
  name = "admin-assume-role"
  group  = "${aws_iam_group.admin.id}"
  policy = "${data.aws_iam_policy_document.admin_group.json}"
  provider = "aws.master"
}

resource "aws_iam_group" "engineer" {
  name = "Engineer"
  provider = "aws.master"
}

resource "aws_iam_group_policy" "mfa_engineer" {
  name = "mfa-policy"
  group  = "${aws_iam_group.engineer.id}"
  policy = "${data.aws_iam_policy_document.mfa.json}"
  provider = "aws.master"
}

resource "aws_iam_group_policy" "engineer_assume_role" {
  name = "engineer-assume-role"
  group  = "${aws_iam_group.engineer.id}"
  policy = "${data.aws_iam_policy_document.engineer_group.json}"
  provider = "aws.master"
}

resource "aws_iam_group" "security_audit" {
  name = "Audit"
  provider = "aws.master"
}

resource "aws_iam_group_policy" "mfa_security" {
  name = "mfa-policy"
  group  = "${aws_iam_group.security_audit.id}"
  policy = "${data.aws_iam_policy_document.mfa.json}"
  provider = "aws.master"
}

resource "aws_iam_group_policy" "security_audit_assume_role" {
  name = "security-audit-assume-role"
  group  = "${aws_iam_group.security_audit.id}"
  policy = "${data.aws_iam_policy_document.security_audit_group.json}"
  provider = "aws.master"
}

resource "aws_iam_group" "finance" {
  name = "Finance"
  provider = "aws.master"
}

resource "aws_iam_group_policy" "mfa_finance" {
  name = "mfa-policy"
  group  = "${aws_iam_group.finance.id}"
  policy = "${data.aws_iam_policy_document.mfa.json}"
  provider = "aws.master"
}

resource "aws_iam_group_policy_attachment" "billing_attach" {
  group  = "${aws_iam_group.finance.id}"
  policy_arn = "${var.billing_default_arn}"
  provider = "aws.master"
}

resource "aws_cloudtrail" "master-cloudtrail" {
  name = "master-cloudtrail"
  s3_bucket_name = "${aws_s3_bucket.cloudtrail.id}"
  is_multi_region_trail = true
  enable_log_file_validation = true
  kms_key_id = "${aws_kms_key.cloudtrail.arn}"
  include_global_service_events = true
  provider = "aws.master"
}

resource "aws_organizations_policy" "scp-policy" {
  name = "ProtectAccounts"
  description = "Deny anyone from doing destructive actions"
  content = <<CONTENT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail",
        "cloudtrail:DeleteTrail",
        "cloudtrail:PutEventSelectors"
      ],
      "Resource": "*"
    }
  ]
}
CONTENT
  provider = "aws.master"
}
