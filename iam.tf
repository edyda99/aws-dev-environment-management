resource "aws_iam_role" "lambda_creation_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_creation_policy" {
  name        = "lambda_execution_policy"
  description = "A policy for lambda to manage ECS and EC2 resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ec2:CreateVpcEndpoint",
          "ec2:DeleteVpcEndpoint",
          "ec2:DescribeVpcEndpoints",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "*",//will be updated later
        Effect   = "Allow"
      },
    ],
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_creation_attach" {
  role       = aws_iam_role.lambda_creation_role.name
  policy_arn = aws_iam_policy.lambda_creation_policy.arn
}

resource "aws_iam_role" "lambda_cleanup_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_cleanup_policy" {
  name        = "lambda_execution_policy"
  description = "A policy for lambda to manage ECS and EC2 resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ec2:DescribeVpcEndpoints",
          "ec2:DeleteVpcEndpoints",
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "*",//will be updated later
        Effect   = "Allow"
      },
    ],
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_cleanup_attach" {
  role       = aws_iam_role.lambda_cleanup_role.name
  policy_arn = aws_iam_policy.lambda_cleanup_policy.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_run_cleanup_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_weekday_EOD.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_run_create_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.creation_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_weekday_morning.arn
}