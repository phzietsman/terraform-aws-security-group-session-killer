terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.10.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module session_killer {
    source = "../"

    naming_prefix = "paulz-play"
}