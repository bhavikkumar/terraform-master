module "cloudtrail-s3-kms" {
  source                = "./modules/cloudtrail-s3-kms"
  aws_region            = "${var.aws_default_region}"
  cloudtrail_account_id = "${var.master_account_id}"
  domain_name           = "${var.domain_name}"
  operations_account_id = "${aws_organizations_account.operations.id}"
  tags                  = "${merge(local.common_tags, var.tags)}"

  providers = {
    aws = "aws.operations"
  }
}

module "organization_cloudtrail" {
  source             = "./modules/cloudtrail"
  cloudtrail_name    = "CloudTrail"
  cloudtrail_kms_key = "${module.cloudtrail-s3-kms.kms_key_arn}"
  s3_bucket          = "${module.cloudtrail-s3-kms.s3_bucket}"
  tags               = "${merge(local.common_tags, var.tags)}"

  providers = {
    aws = "aws.master"
  }
}
