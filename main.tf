terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    key     = "common/master"
    encrypt = true
  }

  required_providers {
    aws = ">= 2.49.0"
  }
}

locals {
  common_tags = {
    Owner       = "global"
    Environment = "production"
  }
}

provider "aws" {
  region                      = var.aws_default_region
  version                     = "2.56.0"
  profile                     = var.profile
  skip_credentials_validation = true
}

provider "aws" {
  alias  = "master"
  region = var.aws_default_region
  allowed_account_ids = [
    var.master_account_id,
  ]
  profile = var.profile
}

provider "aws" {
  alias   = "identity"
  region  = var.aws_default_region
  profile = var.profile

  allowed_account_ids = [
    var.master_account_id,
    aws_organizations_account.identity.id,
  ]

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.identity.id}:role/OrganizationAccountAccessRole"
    session_name = "terraform"
  }
}

provider "aws" {
  alias   = "operations"
  region  = var.aws_default_region
  profile = var.profile

  allowed_account_ids = [
    var.master_account_id,
    aws_organizations_account.operations.id,
  ]

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole"
    session_name = "terraform"
  }
}

provider "aws" {
  alias   = "development"
  region  = var.aws_default_region
  profile = var.profile

  allowed_account_ids = [
    var.master_account_id,
    aws_organizations_account.development.id,
  ]

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.development.id}:role/OrganizationAccountAccessRole"
    session_name = "terraform"
  }
}

provider "aws" {
  alias   = "production"
  region  = var.aws_default_region
  profile = var.profile

  allowed_account_ids = [
    var.master_account_id,
    aws_organizations_account.production.id,
  ]

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.production.id}:role/OrganizationAccountAccessRole"
    session_name = "terraform"
  }
}

module "terraform" {
  source      = "./modules/terraform-state"
  aws_region  = var.aws_default_region
  account_id  = aws_organizations_account.operations.id
  domain_name = var.domain_name
  tags        = merge(local.common_tags, var.tags)

  providers = {
    aws = aws.operations
  }
}

resource "aws_iam_account_alias" "master" {
  account_alias = "${var.account_prefix}-master"
  provider      = aws.master
}

resource "aws_iam_account_alias" "identity" {
  account_alias = var.account_prefix
  provider      = aws.identity
}

resource "aws_iam_account_alias" "operations" {
  account_alias = "${var.account_prefix}-operations"
  provider      = aws.operations
}

resource "aws_iam_account_alias" "development" {
  account_alias = "${var.account_prefix}-development"
  provider      = aws.development
}

resource "aws_iam_account_alias" "production" {
  account_alias = "${var.account_prefix}-production"
  provider      = aws.production
}

module "iam-assume-roles-master" {
  source                     = "./modules/iam-assume-roles"
  account_id                 = aws_organizations_account.identity.id
  enable_read_only_for_admin = true
  tags                       = merge(local.common_tags, var.tags)

  providers = {
    aws = aws.master
  }
}

module "iam-assume-roles-identity" {
  source                     = "./modules/iam-assume-roles"
  account_id                 = aws_organizations_account.identity.id
  enable_read_only_for_admin = true
  tags                       = merge(local.common_tags, var.tags)

  providers = {
    aws = aws.identity
  }
}

module "iam-assume-roles-operations" {
  source     = "./modules/iam-assume-roles"
  account_id = aws_organizations_account.identity.id
  tags       = merge(local.common_tags, var.tags)

  providers = {
    aws = aws.operations
  }
}

module "iam-assume-roles-development" {
  source     = "./modules/iam-assume-roles"
  account_id = aws_organizations_account.identity.id
  tags       = merge(local.common_tags, var.tags)

  providers = {
    aws = aws.development
  }
}

module "iam-assume-roles-production" {
  source     = "./modules/iam-assume-roles"
  account_id = aws_organizations_account.identity.id
  tags       = merge(local.common_tags, var.tags)

  providers = {
    aws = aws.production
  }
}

