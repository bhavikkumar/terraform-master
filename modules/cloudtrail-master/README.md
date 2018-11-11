# cloudtrail-master

This terraform module which creates the cloudtrail KMS key and S3 bucket which can be used for cloudtrail resources.

## Features
This module creates the following resources which can be used for CloudTrail.
- S3 bucket
- KMS Key
- KMS Key Alias

## Usage
```
module "cloudtrail" {
  source = "./modules/cloudtrail-master"
  aws_region = "${var.aws_default_region}"
  cloudtrail_account_id = "${aws_organizations_account.operations.id}"
  account_id_list = ["${aws_organizations_account.operations.id}", "${var.master_account_id}"]
  domain_name = "${var.domain_name}"
  providers = {
    aws = "aws.operations"
  }
}
```

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
aws_region | The AWS Region to create resources | string | - | yes
cloudtrail_account_id | The account id where the resources will be create | string | - | yes
account_id_list | The list of account ids which need access to the KMS key and S3 bucket | list | - | yes
domain_name | The domain name which will be used as the suffix for the s3 bucket | string | - | yes
tags | A map of tags to add to all resources | map | `{}` | no

## Outputs
Name | Description
---- | -----------
kms_key_arn | The ARN of the KMS Key which CloudTrail will use to encrypt logs
s3_bucket | The name of the S3 bucket where CloudTrail logs will be stored
