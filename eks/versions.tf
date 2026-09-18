terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Local state is fine for a solo lab exercise. If you want remote state
  # (e.g. to demonstrate best practice), uncomment and point this at an
  # S3 bucket + DynamoDB lock table you create first:
  #
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket"
  #   key            = "harness-lab/eks/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "harness-fde-lab"
      ManagedBy   = "terraform"
      Environment = "sandbox"
    }
  }
}
