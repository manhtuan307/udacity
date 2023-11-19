# Define the output variable for the lambda function.
output "lambda_arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = aws_lambda_function.demo_lambda_function.arn
}
