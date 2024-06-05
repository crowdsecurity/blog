provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.assume_role_arn
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
  assume_role {
    role_arn = var.assume_role_arn
  }
}