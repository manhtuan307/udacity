terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "udacity"
  region  = var.aws_region
}

data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "greet_lambda.py" 
  output_path = "greet_lambda.zip"
}

data "aws_iam_policy_document" "lambda_assum_role_policy"{
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_function_logs_policy" {
  name        = "lambda_function_logs_policy"
  path        = "/"
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect: "Allow"
        Resource: "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {  
  name = "lambda-execution-role"  
  assume_role_policy = data.aws_iam_policy_document.lambda_assum_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_function_logs_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_function_logs_policy.arn
}

resource "aws_lambda_function" "demo_lambda_function" {
    function_name = "DemoLambdaFunc"
    description   = "Example Python Lambda Function that print greeting message"
    filename      = "greet_lambda.zip"
    source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
    role          = aws_iam_role.lambda_role.arn
    runtime       = "python3.9"
    handler       = "greet_lambda.lambda_handler"
    memory_size   = 128
    timeout       = 30

    environment{
      variables = {
        greeting = "Demo Python Lambda Function"
      }
    }

    depends_on = [aws_iam_role_policy_attachment.lambda_function_logs_policy]
}