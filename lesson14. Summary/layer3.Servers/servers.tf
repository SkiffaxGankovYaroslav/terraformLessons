variable "ami_linux" {
    description = "Specify ami for instance"
    type = string
    default = "ami-052efd3df9dad4825"
}

variable "instance_type" {
    description = "Specify instance type. Default: t3.nano"
    type = string
    default = "t3.nano"
}

variable "number_of_servers" {
    description = "Specify number of instances"
    default = 1
}

variable "subnet_ids" {
    description = "List of public subnets' ids"
}

variable "file_for_user_data" {
    description = "Specify path ot file with user data. Default: 'user_data.sh'"
    default = "user_data.sh"
}

variable "sg_id" {
    description = "Security Groups' ID for the instances"
}

variable "server_name" {
  description = "Name of the servers"
  default = "skiff"
}

variable "key_pair_name" {
  description = "Name of the key pair"
  default = "devops-poligon-master"
}

resource "aws_instance" "skiff_webserver1" {
    count = var.number_of_servers
    ami = "ami-052efd3df9dad4825"
    instance_type = var.instance_type
    subnet_id = element(var.subnet_ids,count.index)
    vpc_security_group_ids = var.sg_id
    user_data = file(var.file_for_user_data)
    key_name = var.key_pair_name
    tags = {
        Name = "${var.server_name}-${count.index+1}"
    }
#       owner = "yaroslav.gankov"
#       var_owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
#       Learning = "Terraform"
#   }
}

output "id_aws_instances" {
  value = aws_instance.skiff_webserver1[*].id
}