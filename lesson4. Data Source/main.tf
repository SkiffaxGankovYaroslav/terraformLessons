#using data source for existing resources
provider "aws" {
  region = "us-east-1"
}

#какую VPC будем искать (по тегу)
variable "name_of_VPC" {
  type = string
  default = "10.0.x.x-main"
}

# data "aws_availability_zones" "working" {}
# data "aws_caller_identity" "current" {} #аккаунт ID, пригодится в дальнейшем для создания IAM, docker и т.д.
# data "aws_region" "current" {}
# data "aws_vpcs" "current" {}

data "aws_vpc" "searchingVPC" {
  #filter for VPC results
  tags = {
    Name = var.name_of_VPC
  }
}

#находим external subnets
data "aws_subnets" "ext_subnet" {
  filter {
    name = "vpc-id"
    #values = ["vpc-0465e4ae2df3296b3"]
    values = [data.aws_vpc.searchingVPC.id]
  }
  filter {
    name = "tag:Name"
    values = ["*external*"]
  }
}



# #create subnet in the my VPC
# resource "aws_subnet" "prod_subnet_1" {
#   vpc_id = data.aws_vpc.searchingVPC.id
#   availability_zone = data.aws_availability_zones.working.names[0]
#   cidr_block = "192.166.50.0/24"
#   tags = {
#     Owner = var.owner_or_creator_name #using variable "owner_or_creator_name" from file "variables.tf"
#     Name = "Subnet created by Terraform"
#   }
# }

# #autosearch for latest image id
# data "aws_ami" "latest_ubuntu" {
#   owners = ["amazon"]
#   most_recent = true #latest
#   #filter all images with owner "amazon" by name that below
#   filter {
#     name = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64*"] #part of the AMI-name
#   }
# }

# output "data_aws_availability_zones" {
#   value = data.aws_availability_zones.working.names
# }

# output "data_aws_caller_identity" {
#   value = data.aws_caller_identity.current.account_id
# }

# output "data_aws_region_name" {
#   value = data.aws_region.current.name
# }

# output "data_aws_region_description" {
#   value = data.aws_region.current.description
# }

# output "data_aws_vpcs" {
#   value = data.aws_vpcs.current.ids
# }

# output "data_vpc_ip" {
#   value = data.aws_vpcs.current.ids
# }

# output "data_vpc_prod" {
#   value = data.aws_vpc.searchingVPC.id
# }

# output "data_ami_id" {
#   value = data.aws_ami.latest_ubuntu.id
# }

# output "data_ami_name" {
#   value = data.aws_ami.latest_ubuntu.name
# }

output "data_aws_subnets" {
  value = data.aws_subnets.ext_subnet.ids
}