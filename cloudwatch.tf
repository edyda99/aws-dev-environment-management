# CloudWatch Event Rule for End of Day Cleanup (Monday-Friday)
resource "aws_cloudwatch_event_rule" "every_weekday_EOD" {
  name                = "every-weekday-eof"
  description         = "Triggers at a specified time for daily cleanup on weekdays"
  schedule_expression = "cron(0 16 ? * MON-FRI *)"
  is_enabled          = true
}

# CloudWatch Event Rule for Morning Infrastructure Setup (Monday-Friday)
resource "aws_cloudwatch_event_rule" "every_weekday_morning" {
  name                = "every-weekday-morning"
  description         = "Triggers in the morning for infrastructure setup on weekdays"
  schedule_expression = "cron(0 4 ? * MON-FRI *)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "run_cleanup_lambda_daily" {
  rule      = aws_cloudwatch_event_rule.every_weekday_EOD.name
  target_id = "runCleanupLambdaDaily"
  arn       = aws_lambda_function.cleanup_lambda.arn
}

resource "aws_cloudwatch_event_target" "run_populate_lambda_daily" {
  rule      = aws_cloudwatch_event_rule.every_weekday_morning.name
  target_id = "runPopulateDaily"
  arn       = aws_lambda_function.creation_lambda.arn
}