terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
  }

  required_version = ">= 1.9.1"
}

