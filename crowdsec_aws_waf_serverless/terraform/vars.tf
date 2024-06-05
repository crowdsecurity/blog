variable "aws_region" {
  description = "aws region"
}

variable "assume_role_arn" {
  description = "role to assume to deploy resources in the account"
}

variable "aws_account_id" {
  description = "aws account id"
}

variable "logging_bucket_name" {
  description = "name of the bucket to store cloudfront logs"
}

variable "lambda_bucket_name" {
  description = "name of the bucket to store lambdas"
}

variable subnet {
  description = "subnet to deploy the resources"
  type = string
}

variable vpc_id {
  description = "vpc id to deploy the resources"
  type = string
}

variable "key_name" {
  description = "key name to ssh into the instance"
  type = string
}