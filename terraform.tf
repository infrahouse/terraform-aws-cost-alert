terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.56"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
