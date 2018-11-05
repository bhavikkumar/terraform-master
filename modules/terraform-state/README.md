# terraform-state

This terraform module can be used for creating the required resources to store Terraform state.

## Features
This module creates the following resources which can be used by users of Terraform.
- S3 bucket
- KMS Key
- KMS Key Alias
- DynamoDB Table

## Usage
```
module "terraform" {
  source = "./modules/terraform-state"
  aws_region = "${var.aws_default_region}"
  account_id = "${aws_organizations_account.operations.id}"
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
account_id | The account id where the resources will be create | string | - | yes
domain_name | The domain name which will be used as the suffix for the s3 bucket | string | - | yes

## Outputs
Name | Description
---- | -----------
kms_key_arn | The ARN of the KMS Key which Terraform will use to encrypt the state
s3_bucket | The name of the S3 bucket where Terraform will use to store its state
dynamodb_table | The name of the dynamodb table which can be used for locking the state
