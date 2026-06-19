terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
  }

  required_version = ">= 1.9.1"
}
