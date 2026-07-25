variable "bot_token" {
  description = "Slack bot token with channels:read, channels:manage, channels:join scopes. Used to create and manage channels"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod) used to prefix every channel name so environments don't collide in the same workspace"
  type        = string
}

variable "channel_names" {
  description = "Base channel names (no environment prefix, no leading '#') to create, one per Alertmanager receiver"
  type        = list(string)
}
