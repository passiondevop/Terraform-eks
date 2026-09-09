terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.1"
    }
      http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}
provider "aws" {
  region = "us-west-2"
}