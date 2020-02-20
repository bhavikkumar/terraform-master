output cloudwatch_log_arn {
  value = aws_cloudwatch_log_group.cloudtrail.arn
}

output cloudwatch_log_group_name {
  value = aws_cloudwatch_log_group.cloudtrail.name
}
