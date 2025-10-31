variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "allowed_ssh_cidr" { type = string }
variable "additional_ssh_cidrs" {
  type    = list(string)
  default = []
}

resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP from all and SSH from allowed CIDR(s)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (primary)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  dynamic "ingress" {
    for_each = var.additional_ssh_cidrs
    content {
      description = "SSH (additional)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-web-sg"
    Project = var.project_name
  }
}

output "security_group_id" { value = aws_security_group.web_sg.id }


