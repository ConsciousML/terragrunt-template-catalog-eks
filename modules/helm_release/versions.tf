terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.53.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
  required_version = ">= 1.9.1"
}
