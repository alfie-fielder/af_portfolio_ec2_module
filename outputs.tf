output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.ec2.id
}

output "arn" {
  description = "The ARN of the EC2 instance."
  value       = aws_instance.ec2.arn
}

output "private_ip" {
  description = "The private IP address of the EC2 instance."
  value       = aws_instance.ec2.private_ip
}

output "public_ip" {
  description = "The public IP address of the EC2 instance. Empty string if no public IP is associated."
  value       = aws_instance.ec2.public_ip
}

output "private_dns" {
  description = "The private DNS name of the EC2 instance."
  value       = aws_instance.ec2.private_dns
}

output "public_dns" {
  description = "The public DNS name of the EC2 instance. Empty string if no public IP is associated."
  value       = aws_instance.ec2.public_dns
}

output "availability_zone" {
  description = "The availability zone the instance was launched in, as derived from the subnet."
  value       = aws_instance.ec2.availability_zone
}

output "subnet_id" {
  description = "The subnet ID the instance was launched in."
  value       = aws_instance.ec2.subnet_id
}

output "instance_state" {
  description = "The current state of the instance."
  value       = aws_instance.ec2.instance_state
}