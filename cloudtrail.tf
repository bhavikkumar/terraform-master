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

module "cloudtrail-operations" {
  source             = "./modules/cloudtrail"
  cloudtrail_name    = "operations"
  cloudtrail_kms_key = "${module.cloudtrail.kms_key_arn}"
  cloudwatch_kms_key = "${aws_kms_alias.default.arn}"
  s3_bucket          = "${module.cloudtrail.s3_bucket}"
  tags               = "${merge(local.common_tags, var.tags)}"

  providers = {
    aws = "aws.operations"
  }
}

module "cloudtrail-master" {
  source             = "./modules/cloudtrail"
  cloudtrail_name    = "master"
  cloudtrail_kms_key = "${module.cloudtrail.kms_key_arn}"
  cloudwatch_kms_key = "${aws_kms_alias.default.arn}"
  s3_bucket          = "${module.cloudtrail.s3_bucket}"
  tags               = "${merge(local.common_tags, var.tags)}"

  providers = {
    aws = "aws.master"
  }
}

module "cloudtrail-development" {
  source             = "./modules/cloudtrail"
  cloudtrail_name    = "development"
  cloudtrail_kms_key = "${module.cloudtrail.kms_key_arn}"
  cloudwatch_kms_key = "${aws_kms_alias.default.arn}"
  s3_bucket          = "${module.cloudtrail.s3_bucket}"
  tags               = "${merge(local.common_tags, var.tags)}"

  providers = {
    aws = "aws.development"
  }
}

module "cloudtrail-production" {
  source             = "./modules/cloudtrail"
  cloudtrail_name    = "production"
  cloudtrail_kms_key = "${module.cloudtrail.kms_key_arn}"
  cloudwatch_kms_key = "${aws_kms_alias.default.arn}"
  s3_bucket          = "${module.cloudtrail.s3_bucket}"
  tags               = "${merge(local.common_tags, var.tags)}"

  providers = {
    aws = "aws.production"
  }
}
