variable "project_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "key_name" { type = string }

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    set -e
    yum update -y
    amazon-linux-extras install docker -y || yum install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user || true
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    yum install -y python3 git
  EOT
}

resource "aws_instance" "web" {
  count                       = length(var.subnet_ids)
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = local.user_data

  tags = {
    Name    = "${var.project_name}-web-${count.index + 1}"
    Project = var.project_name
    Role    = "web"
  }
}

output "public_ips" { value = [for i in aws_instance.web : i.public_ip] }
output "instance_ids" { value = [for i in aws_instance.web : i.id] }


