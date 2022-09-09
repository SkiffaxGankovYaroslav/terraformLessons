#--------------------------------------
#module for test
#--------------------------------------

#directive for remote-state-file storage for terraform
# terraform {
#   backend "s3" {
#     bucket="bucket-from-lambda-skiff"
#     key = "terraform.tfstate"
#     region = "us-east-1"
#   }
# }

#VARIABLES
variable "vpc_cidr" {
    default = "10.173.0.0/16"
}

variable "env" {
    default = "dev"
}

variable "public_subnets_cidrs" {
    default = [
        "10.173.1.0/24",
        "10.173.2.0/24",
    ]
}

#DATA
#read availability zones in our region. It is need for attaching different AZ to subnets
data "aws_availability_zones" "available_zones" {
    state = "available"
}

#RESOURCE
resource "aws_vpc" "skiff_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "test-TerForm-skiff-${var.env}"
        Owner = var.owner_or_creator_name
        Learning = "Terraform"
    }
}
resource "aws_internet_gateway" "main_gateway" {
    vpc_id = aws_vpc.skiff_vpc.id
}
#dynamic creation of any number subnets
resource "aws_subnet" "public_subnets" {
    count = length(var.public_subnets_cidrs)
    vpc_id = aws_vpc.skiff_vpc.id
    cidr_block = element(var.public_subnets_cidrs, count.index)
    availability_zone = data.aws_availability_zones.available_zones.names[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "test-TerForm-skiff-${var.env}"
        Creator = var.owner_or_creator_name
        Learning = "Terraform"
    }
}
resource "aws_route_table" "public_subnets" {
    vpc_id = aws_vpc.skiff_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_gateway.id
    }
    tags = {
        Name = "test-TerForm-skiff-${var.env}"
        Creator = var.owner_or_creator_name
        Learning = "Terraform"
    }
}

resource "aws_route_table_association" "public_routes_skiff" {
    count = length(aws_subnet.public_subnets[*].id)
    route_table_id = aws_route_table.public_subnets.id
    subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
}

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