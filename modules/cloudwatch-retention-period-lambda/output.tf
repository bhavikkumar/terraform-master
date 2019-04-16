output "log_group" {
  value       = "${aws_cloudwatch_log_group.lambda.arn}"
  description = "The CloudWatch Log Group ARN"
}
