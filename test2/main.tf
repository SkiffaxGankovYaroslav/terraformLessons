provider "aws" {
  default_tags {
    tags = {
      Learning = "Terraform"
      Owner = "yaroslav.gankov"
      Creator = "yaroslav.gankov"
    }
  }
}

variable "env" {
    default = "prod"
}

variable "prod_owner" {
  default = "skiff"
}

variable "noprod_owner" {
  default = "dyadya_vasya"
}

#variable for lookup
variable "instance_size" {
  default = {
    "prod" = "t3.medium"
    "test" = "t3.micro"
    "dev" = "t3.nano"
  }
}

variable "port_to_open_in_sg" {
  description = "list of opened ports in the server"
  type = list
  #default = ["443", "22", "80", "81", "1488"]
  default = [0]
}

resource "aws_security_group" "SG_skiff" {
  name        = "test-group-skiff-delete"
  description = "delete this group for test"
  vpc_id      = "vpc-0465e4ae2df3296b3"
  
  #inbound
  dynamic "ingress" {
    for_each = var.port_to_open_in_sg
    #for_each = 
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      #если в списке портов указан 0, то указываем все протоколы "-1"; в ином случае указываем "tcp"
      protocol    = can("${index(var.port_to_open_in_sg,0)}") == true ? "-1" : "tcp"
      cidr_blocks = can("${index(var.port_to_open_in_sg,0)}") == true ? ["10.188.0.0/16"] : ["0.0.0.0/0"]
    }
  }

  #outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #all the protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "delete this group for test"
  }
}

output "index1" {
  value = can("${index(var.port_to_open_in_sg,0)}") == false ? "ololo" : "alala"
}
  

# resource "aws_instance" "skiff_webserver1" {
#   ami = "ami-052efd3df9dad4825"
#   instance_type = var.env == "prod" ? "t3.small" : "t3.nano"

#   tags = {
#       Name = "TerFormCond_skiff"
#       owner = "yaroslav.gankov"
#       var_owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
#       Learning = "Terraform"
#   }
#   # dynamic "tags" {
#   #   for_each = {
#   #     Name = "TerFormCond_skiff"
#   #     owner = "yaroslav.gankov"
#   #     Learning = "Terraform"
#   #   }
#   #   content {
#   #     key = tag.key
#   #     value = tag.value
#   #     propagate_at_launch = true
#   #   }
#   # }

# }

# resource "aws_instance" "skiff_webserver1_test" {
#   count = var.env == "prod" ? 0 : 1
#   ami = "ami-052efd3df9dad4825"
#   instance_type = var.env == "prod" ? "t3.small" : "t3.nano"

#   tags = {
#       Name = "TerFormCond_skiff_test"
#       owner = "yaroslav.gankov"
#       #var_owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
#       Learning = "Terraform"
#   }
#   # dynamic "tags" {
#   #   for_each = {
#   #     Name = "TerFormCond_skiff"
#   #     owner = "yaroslav.gankov"
#   #     Learning = "Terraform"
#   #   }
#   #   content {
#   #     key = tag.key
#   #     value = tag.value
#   #     propagate_at_launch = true
#   #   }
#   # }

# }

# #instance with lookup
# resource "aws_instance" "skiff_webserver1_lookup" {
#   ami = "ami-052efd3df9dad4825"
#   instance_type = lookup(var.instance_size, var.env)
#   tags = {
#       Name = "TerFormLookup_skiff"
#       owner = "yaroslav.gankov"
#       var_owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
#       Learning = "Terraform"
#   }
# }