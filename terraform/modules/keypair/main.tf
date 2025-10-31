variable "project_name" { type = string }

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-ec2-key"
  public_key = tls_private_key.ssh.public_key_openssh
  tags = {
    Name    = "${var.project_name}-ec2-key"
    Project = var.project_name
  }
}

resource "aws_secretsmanager_secret" "ssh_private_key" {
  name = "${var.project_name}-ec2-ssh-private-key"
  tags = {
    Project = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = tls_private_key.ssh.private_key_pem
}

output "key_name" { value = aws_key_pair.this.key_name }
output "secret_arn" { value = aws_secretsmanager_secret.ssh_private_key.arn }
output "secret_name" { value = aws_secretsmanager_secret.ssh_private_key.name }


