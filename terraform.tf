terraform {
  backend "s3" {
    bucket = "controlshift-terraform-state-west1"
    key = "controlshift-terraform-state-prod/terraform.tfstate"
    region = "us-west-1"
    encrypt = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.26.0"
    }
  }
}
