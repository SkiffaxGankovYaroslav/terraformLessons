#OUTPUT
#outputs needs for communication with others developers
output "vpc_id" {
    value = aws_vpc.skiff_vpc.id
}

output "vpc_cidr" {
    value = aws_vpc.skiff_vpc.cidr_block
}

output "public_subnet_ids" {
    value = aws_subnet.public_subnets[*].id
}

output "internal_subnet_ids" {
  value = aws_subnet.internal_subnets[*].id
}

output "DB_subnet_ids" {
  value = aws_subnet.DB_subnets[*].id
}

output "vpc_cidr_mask16" {
    value = var.vpc_cidr_mask16
}