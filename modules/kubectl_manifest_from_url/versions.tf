terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.4"
    }
  }

  required_version = ">= 1.9.1"
}
