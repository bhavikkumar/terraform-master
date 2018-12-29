# cloudtrail

This terraform module creates multi region cloudtrail and cloudwatch logs.

## Usage
```
module "cloudtrail" {
  source             = "./modules/cloudtrail"
  cloudtrail_name    = "cloudtrail"
  cloudtrail_kms_key = "${module.cloudtrail-s3-kms.kms_key_arn}"
  s3_bucket          = "${module.cloudtrail-s3-kms.s3_bucket}"
  providers = {
    aws = "aws.operations"
  }
}
```

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
cloudtrail_name | The name to give the trail | string | `cloudtrail` | no
cloudwatch_log_retention_period | The number of days to retain the cloudwatch logs for | number | `1` | no
is_organization_trail | Specifies whether the trail is an AWS Organizations trail. | boolean | `true` |  no
s3_bucket | The S3 Bucket which will store the CloudTrail logs | string | - | yes
tags | A map of tags to add to all resources | map | `{}` | no

## Outputs
Name | Description
---- | -----------
cloudwatch_log_arn | The ARN of the cloudwatch log group
cloudwatch_log_group_name | The name of the cloudwatch log group
