output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.my_subnet.id
}

output "subnet_arn" {
  description = "The ARN of the subnet"
  value       = aws_subnet.my_subnet.arn
}

output "availability_zone" {
  description = "The availability zone of the subnet"
  value       = aws_subnet.my_subnet.availability_zone
}

output "cidr_block" {
  description = "The CIDR block of the subnet"
  value       = aws_subnet.my_subnet.cidr_block
}
