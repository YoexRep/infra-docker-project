variable "project_name" {
  description = "Project tag/name for resources"
  type        = string
  default     = "infra-docker-project"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH (22). Example: 1.2.3.4/32"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones / public subnets"
  type        = number
  default     = 2
}

variable "additional_ssh_cidrs" {
  description = "Additional CIDRs allowed to SSH (22), e.g. for CI runners"
  type        = list(string)
  default     = []
}


