# cloudtrail

This terraform module creates cloudtrail audit trail and cloudwatch logs

## Usage
```
module "cloudtrail" {
  source             = "./modules/cloudtrail"
  cloudtrail_kms_key = "${module.cloudtrail.kms_key_arn}"
  cloudwatch_kms_key = "${aws_kms_key.default.arn}"
  s3_bucket          = "${module.cloudtrail.s3_bucket}"
  providers = {
    aws = "aws.operations"
  }
}
```

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
cloudtrail_kms_key | The ARN of the KMS Key which will be used to encrypt the CloudTrail logs | string | - | yes
cloudwatch_kms_key | The ARN of the KMS Key which will be used to encrypt the CloudWatch logs | string | - | yes
s3_bucket | The S3 Bucket which will store the CloudTrail logs | string | - | yes
tags | A map of tags to add to all resources | map | `{}` | no

## Outputs
Name | Description
---- | -----------
