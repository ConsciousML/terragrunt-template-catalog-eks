output "channel_names" {
  description = "Environment-prefixed names of the channels that were created"
  value       = [for c in slack_conversation.this : c.name]
}
