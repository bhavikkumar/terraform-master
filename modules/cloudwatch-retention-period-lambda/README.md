# cloudwatch-retention-period-lambda

This terraform module can be used to deploy a lambda function which will set the retention period on log groups which are created or have their retention period modified after being created.

## Features
This module creates the following resources which can be used by users of Terraform.
- CloudWatch Log Group for the Lambda Function
- IAM Role for the Lambda Function
- Lambda Function
- CloudWatch Event Rule

## Usage
```
module "retention-period-lambda" {
  source               = "./modules/cloudwatch-retention-period-lambda"
  kms_key_arn          = "${aws_kms_key.default.arn}"
  log_retention_period = 14
  s3_bucket            = "artifact.bhavik.io"
  s3_folder            = "lambda"
  tags                 = "${merge(local.common_tags, var.tags)}"
  version              = "1.0.2"
  provider             = "aws.operations"
}
```

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
app_version | The version of the lambda function to deploy | string | - | yes
kms_key_arn | The KMS Key ARN which will be used to encrypt enviornment variables | string | - | yes
log_retention_period | The retention period to set for all log groups in days | number | `14` | no
s3_bucket | The S3 Bucket which stores the lambda function | string | - | yes
s3_folder | The folder which the lambda function is stored in | - | no
tags | A map of tags to add to all resources | map | `{}` | no

## Outputs
Name | Description
---- | -----------
log_group | The CloudWatch Log group where the lambda function will send logs
