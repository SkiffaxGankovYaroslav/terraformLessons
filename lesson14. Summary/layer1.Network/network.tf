# #directive for remote-state-file storage for terraform (for non-module structure)
# terraform {
#   backend "s3" {
#     bucket="bucket-from-lambda-skiff"
#     key = "layer1.Network/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

#DATA
#read availability zones in our region. It is need for attaching different AZ to subnets
data "aws_availability_zones" "available_zones" {
    state = "available"
}

#RESOURCES
resource "aws_vpc" "skiff_vpc" {
    cidr_block = local.vpc_cidr
    tags = {
        Name = "${var.vpc_cidr_mask16}.x.x-${var.name_project}-${var.env}"
    }
}
resource "aws_internet_gateway" "main_gateway" {
    vpc_id = aws_vpc.skiff_vpc.id
    tags = {
        Name = "${var.vpc_cidr_mask16}.x.x-${var.name_project}-${var.env}"
    }
}

#start create public subnets
resource "aws_subnet" "public_subnets" {
    count = var.count_subnets
    vpc_id = aws_vpc.skiff_vpc.id
    #cidr_block = element(var.public_subnets_cidrs, count.index)
    cidr_block = "${var.vpc_cidr_mask16}.${count.index+1}.0/24"
    #availability_zone = data.aws_availability_zones.available_zones.names[count.index]
    availability_zone = element(data.aws_availability_zones.available_zones.names,count.index)
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.vpc_cidr_mask16}.${count.index+1}.x-${var.name_project}-${var.env}"
    }
}
resource "aws_route_table" "public_subnets" {
    vpc_id = aws_vpc.skiff_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_gateway.id
    }
    tags = {
        Name = "${var.vpc_cidr_mask16}.x.x-${var.name_project}-public-${var.env}"
    }
}
#associate route-table with all of subnets
resource "aws_route_table_association" "public_routes_skiff" {
    count = length(aws_subnet.public_subnets[*].id)
    route_table_id = aws_route_table.public_subnets.id
    subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
}
#end create public subnets

#start create internal subnets
resource "aws_subnet" "internal_subnets" {
    depends_on = [ 
      aws_subnet.public_subnets #должны создаваться после public subnets
    ]
    count = var.count_subnets_internal
    vpc_id = aws_vpc.skiff_vpc.id
    #cidr_block = element(var.public_subnets_cidrs, count.index)
    cidr_block = "${var.vpc_cidr_mask16}.${var.count_subnets+count.index+1}.0/24"
    #availability_zone = data.aws_availability_zones.available_zones.names[count.index]
    availability_zone = element(data.aws_availability_zones.available_zones.names,count.index)
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.vpc_cidr_mask16}.${var.count_subnets+count.index+1}.x-${var.name_project}-internal-${var.env}"
    }
}

resource "aws_route_table" "internal_subnets" {
    vpc_id = aws_vpc.skiff_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ng.id
    }
    tags = {
        Name = "${var.vpc_cidr_mask16}.x.x-${var.name_project}-internal-${var.env}"
    }
}
resource "aws_route_table_association" "internal_routes_skiff" {
    count = length(aws_subnet.internal_subnets[*].id)
    route_table_id = aws_route_table.internal_subnets.id
    subnet_id = element(aws_subnet.internal_subnets[*].id, count.index)
}
resource "aws_eip" "nat" {
    vpc = true
}
resource "aws_nat_gateway" "ng" {
  subnet_id = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.nat.id
  tags = {
        Name = "${var.vpc_cidr_mask16}.x.x-${var.name_project}-${var.env}"
    }
}
#end create internal subnets

#start create DB subnets
resource "aws_subnet" "DB_subnets" {
    depends_on = [
      aws_subnet.internal_subnets #должны создаваться после internal subnets
    ]
    count = var.count_subnets_db
    vpc_id = aws_vpc.skiff_vpc.id
    #cidr_block = element(var.public_subnets_cidrs, count.index)
    cidr_block = "${var.vpc_cidr_mask16}.${var.count_subnets+var.count_subnets_internal+count.index+1}.0/24"
    #availability_zone = data.aws_availability_zones.available_zones.names[count.index]
    availability_zone = element(data.aws_availability_zones.available_zones.names,count.index)
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.vpc_cidr_mask16}.${var.count_subnets+var.count_subnets_internal+count.index+1}.x-${var.name_project}-DB-${var.env}"
    }
}
#end create DB subnets