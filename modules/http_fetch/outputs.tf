output "body" {
  description = "Response body of the HTTP request"
  value       = data.http.this.response_body
}
