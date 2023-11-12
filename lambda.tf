resource "aws_lambda_function" "cleanup_lambda" {
  function_name = "cleanupLambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 320

  filename = "path/to/delete_lambda.zip"

  role = aws_iam_role.lambda_cleanup_role.arn
}

resource "aws_lambda_function" "creation_lambda" {
  function_name = "creationLambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 320

  filename = "path/to/create_lambda.zip"

  role = aws_iam_role.lambda_creation_role.arn
}
