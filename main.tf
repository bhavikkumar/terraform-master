provider "aws" {
  region                      = "${var.aws_default_region}"
  version                     = "~> 1.48.0"
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
