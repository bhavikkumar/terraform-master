provider "aws" {
  region                      = "${var.aws_default_region}"
  version                     = "~> 1.38"
  profile                     = "${var.profile}"
  skip_credentials_validation = true
}

provider "aws" {
  alias               = "master"
  region              = "${var.aws_default_region}"
  allowed_account_ids = ["${var.master_account_id}"]
  profile             = "${var.profile}"
}

provider "aws" {
  alias   = "operations"
  region  = "${var.aws_default_region}"
  profile = "${var.profile}"

  allowed_account_ids = [
    "${var.master_account_id}",
    "${aws_organizations_account.operations.id}"
  ]

  assume_role {
    role_arn      = "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole"
    session_name  = "terraform"
  }
}

provider "aws" {
  alias   = "development"
  region  = "${var.aws_default_region}"
  profile = "${var.profile}"

  allowed_account_ids = [
    "${var.master_account_id}",
    "${aws_organizations_account.development.id}"
  ]

  assume_role {
    role_arn      = "arn:aws:iam::${aws_organizations_account.development.id}:role/OrganizationAccountAccessRole"
    session_name  = "terraform"
  }
}

provider "aws" {
  alias   = "production"
  region  = "${var.aws_default_region}"
  profile = "${var.profile}"

  allowed_account_ids = [
    "${var.master_account_id}",
    "${aws_organizations_account.production.id}"
  ]

  assume_role {
    role_arn      = "arn:aws:iam::${aws_organizations_account.production.id}:role/OrganizationAccountAccessRole"
    session_name  = "terraform"
  }
}

terraform {
 backend "s3" {
   key     = "common/master"
   encrypt = true
 }
}

locals {
  common_tags = {
    Owner       = "global"
    Environment = "production"
  }
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length         = 12
  require_lowercase_characters    = true
  require_numbers                 = true
  require_uppercase_characters    = true
  require_symbols                 = true
  allow_users_to_change_password  = true
  password_reuse_prevention       = true
  max_password_age                = 0
  provider                        = "aws.master"
}

resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
  provider    = "aws.master"
}

resource "aws_organizations_account" "operations" {
  name      = "${var.prefix}-operations"
  email     = "580a5d93-f5c5-46e5-84f0-140c4bb8bcaf@${var.domain_name}"
  provider  = "aws.master"
}

resource "aws_organizations_account" "development" {
  name      = "${var.prefix}-development"
  email     = "d9ebfd25-4f30-44c8-8c59-07f5ce7be59d@${var.domain_name}"
  provider  = "aws.master"
}

resource "aws_organizations_account" "production" {
  name      = "${var.prefix}-production"
  email     = "afb0997b-2275-43f1-a789-4e812f649bbb@${var.domain_name}"
  provider  = "aws.master"
}

resource "aws_iam_account_alias" "master" {
  account_alias = "${var.prefix}-master"
  provider      = "aws.master"
}

resource "aws_iam_account_alias" "operations" {
  account_alias = "${var.prefix}-operations"
  provider      = "aws.operations"
}

resource "aws_iam_account_alias" "development" {
  account_alias = "${var.prefix}-development"
  provider      = "aws.development"
}

resource "aws_iam_account_alias" "production" {
  account_alias = "${var.prefix}-production"
  provider      = "aws.production"
}

module "iam-assume-roles-operations" {
  source            = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"

  providers = {
    aws = "aws.operations"
  }
}

module "iam-assume-roles-development" {
  source            = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"

  providers = {
    aws = "aws.development"
  }
}

module "iam-assume-roles-production" {
  source            = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"

  providers = {
    aws = "aws.production"
  }
}

// Create IAM groups and roles in the master account
resource "aws_iam_group" "admin" {
  name      = "Admin"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_admin" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.admin.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "admin_assume_role" {
  name      = "admin-assume-role"
  group     = "${aws_iam_group.admin.id}"
  policy    = "${data.aws_iam_policy_document.admin_group.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy_attachment" "admin_iam" {
  group       = "${aws_iam_group.admin.id}"
  policy_arn = "${var.iam_admin_arn}"
  provider    = "aws.master"
}

resource "aws_iam_group_policy_attachment" "admin_billing" {
  group       = "${aws_iam_group.admin.id}"
  policy_arn  = "${var.billing_default_arn}"
  provider    = "aws.master"
}

resource "aws_iam_group" "engineer" {
  name      = "Engineer"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_engineer" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.engineer.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "engineer_assume_role" {
  name      = "engineer-assume-role"
  group     = "${aws_iam_group.engineer.id}"
  policy    = "${data.aws_iam_policy_document.engineer_group.json}"
  provider  = "aws.master"
}

resource "aws_iam_group" "security_audit" {
  name      = "Audit"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_security" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.security_audit.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "security_audit_assume_role" {
  name      = "security-audit-assume-role"
  group     = "${aws_iam_group.security_audit.id}"
  policy    = "${data.aws_iam_policy_document.security_audit_group.json}"
  provider  = "aws.master"
}

resource "aws_iam_group" "finance" {
  name      = "Finance"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_finance" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.finance.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy_attachment" "billing_attach" {
  group       = "${aws_iam_group.finance.id}"
  policy_arn  = "${var.billing_default_arn}"
  provider    = "aws.master"
}

resource "aws_kms_key" "default" {
  description = "The default KMS Key used for all services"
  policy      = "${data.aws_iam_policy_document.default_kms_policy.json}"
  tags        = "${merge(local.common_tags, var.tags)}"
  provider    = "aws.operations"
}

resource "aws_kms_alias" "default" {
  name          = "alias/default-key"
  target_key_id = "${aws_kms_key.default.key_id}"
  provider      = "aws.operations"
}

module "cloudtrail" {
  source                = "./modules/cloudtrail-master"
  aws_region            = "${var.aws_default_region}"
  cloudtrail_account_id = "${aws_organizations_account.operations.id}"
  domain_name           = "${var.domain_name}"
  tags                  = "${merge(local.common_tags, var.tags)}"

  account_id_list = [
    "${aws_organizations_account.operations.id}",
    "${var.master_account_id}",
    "${aws_organizations_account.development.id}",
    "${aws_organizations_account.production.id}"
  ]

  providers = {
    aws = "aws.operations"
  }
}

resource "aws_cloudtrail" "operations-cloudtrail" {
  name                          = "cloudtrail"
  s3_bucket_name                = "${module.cloudtrail.s3_bucket}"
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = "${module.cloudtrail.kms_key_arn}"
  include_global_service_events = true
  tags                          = "${merge(local.common_tags, var.tags)}"
  provider                      = "aws.operations"
}

resource "aws_cloudtrail" "master-cloudtrail" {
  name                          = "cloudtrail"
  s3_bucket_name                = "${module.cloudtrail.s3_bucket}"
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = "${module.cloudtrail.kms_key_arn}"
  include_global_service_events = true
  tags                          = "${merge(local.common_tags, var.tags)}"
  provider                      = "aws.master"
}

resource "aws_cloudtrail" "development-cloudtrail" {
  name                          = "cloudtrail"
  s3_bucket_name                = "${module.cloudtrail.s3_bucket}"
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = "${module.cloudtrail.kms_key_arn}"
  include_global_service_events = true
  tags                          = "${merge(local.common_tags, var.tags)}"
  provider                      = "aws.development"
}

resource "aws_cloudtrail" "production-cloudtrail" {
  name                          = "cloudtrail"
  s3_bucket_name                = "${module.cloudtrail.s3_bucket}"
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = "${module.cloudtrail.kms_key_arn}"
  include_global_service_events = true
  tags                          = "${merge(local.common_tags, var.tags)}"
  provider                      = "aws.production"
}

resource "aws_organizations_policy" "scp-policy" {
  name        = "ProtectAccounts"
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

module "terraform" {
  source      = "./modules/terraform-state"
  aws_region  = "${var.aws_default_region}"
  account_id  = "${aws_organizations_account.operations.id}"
  domain_name = "${var.domain_name}"
  tags        = "${merge(local.common_tags, var.tags)}"

  providers = {
    aws = "aws.operations"
  }
}
