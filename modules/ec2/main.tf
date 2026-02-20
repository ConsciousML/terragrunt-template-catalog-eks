#tfsec:ignore:aws-ec2-enforce-http-token-imds
#tfsec:ignore:aws-ec2-enable-at-rest-encryption
resource "aws_instance" "example" {
  ami           = var.ami
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
  tags          = var.tags
}
