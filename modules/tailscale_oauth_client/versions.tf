terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.28.0"
    }
  }

  required_version = ">= 1.9.1"
}
