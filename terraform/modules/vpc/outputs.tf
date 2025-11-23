output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "public_subnet_azs" {
  description = "AZs used for the public subnets"
  value       = [for s in aws_subnet.public : s.availability_zone]
}

output "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  value       = [for s in aws_subnet.public : s.cidr_block]
}
