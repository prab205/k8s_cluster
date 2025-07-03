output "ec2_instance_profile_name" {
  description = "EC2 Instance Profile ARN for EC2 to assume"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.k8s_vpc.id
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = aws_security_group.collective_sg.id
}

output "public_subnet_a_id" {
  description = "The ID of the subnet a"
  value       = aws_subnet.k8s_public_subnet_a.id
}

output "public_subnet_b_id" {
  description = "The ID of the subnet b"
  value       = aws_subnet.k8s_public_subnet_b.id
}