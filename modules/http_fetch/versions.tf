terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
  }

  required_version = ">= 1.9.1"
}
