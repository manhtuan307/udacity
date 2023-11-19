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

resource "aws_iam_role" "lambda_role" {  
  name = "lambda-exec-role"  
  assume_role_policy = data.aws_iam_policy_document.lambda_assum_role_policy.json
}

data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "greet_lambda.py" 
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "demo_lambda_function" {
    function_name = "DemoLambdaFunc"
    description   = "Example Python Lambda Function that print greeting message"
    filename      = "lambda.zip"
    source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
    role          = aws_iam_role.lambda_role.arn
    runtime       = "python3.10"
    handler       = "lambda.lambda_handler"
    memory_size   = 128
    timeout       = 30
}