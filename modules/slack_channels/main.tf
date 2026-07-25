resource "slack_conversation" "this" {
  for_each = toset(var.channel_names)

  name              = "${var.environment}-${each.value}"
  is_private        = false
  permanent_members = []
}
