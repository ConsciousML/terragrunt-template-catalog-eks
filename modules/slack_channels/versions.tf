terraform {
  required_providers {
    slack = {
      source  = "pablovarela/slack"
      version = "= 1.2.2"
    }
  }

  required_version = ">= 1.9.1"
}
