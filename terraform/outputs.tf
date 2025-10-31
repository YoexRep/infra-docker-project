output "public_ips" {
  description = "Public IPs of EC2 instances"
  value       = module.ec2.public_ips
}

output "ssh_private_key_secret_name" {
  description = "Name of the secret in AWS Secrets Manager containing the EC2 SSH private key 5"
  value       = module.keypair.secret_name
}

output "project_tag" {
  value = var.project_name
}


