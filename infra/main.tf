terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
  backend "s3" {
    bucket = "pgr301-2024-terraform-state"
    key    = "60/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

# SQS Queue
resource "aws_sqs_queue" "image_request_queue" {
  name = "image-request-queue-60"
}

# Lambda Function Using Existing IAM Role
resource "aws_lambda_function" "image_generator_lambda" {
  function_name    = "image-generator-lambda"
  filename         = "${path.module}/lambda_sqs.zip"
  handler          = "lambda_sqs.lambda_handler"
  runtime          = "python3.9"
  
  # Use the existing IAM role ARN here
  role = "arn:aws:iam::244530008913:role/Terraform_role_cand60"

  timeout = 30

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
    }
  }

  source_code_hash = filebase64sha256("${path.module}/lambda_sqs.zip")
}

# Event Source Mapping (Link Lambda to SQS)
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_request_queue.arn
  function_name    = aws_lambda_function.image_generator_lambda.arn
  batch_size       = 5
  enabled          = true
}
