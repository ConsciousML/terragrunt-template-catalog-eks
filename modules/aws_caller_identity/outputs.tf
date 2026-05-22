output "arn" {
  description = "ARN of the AWS identity making the API call"
  value       = data.aws_caller_identity.current.arn
}
