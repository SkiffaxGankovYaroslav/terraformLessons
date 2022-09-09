variable "env" {
    description = "Define stage of development: dev, test, prod"
    default = "dev"
}

#which ports should be opened (allowed) in the server
variable "port_to_open_in_sg" {
  description = "list of opened ports in the server"
  type = list
  default = ["443", "22", "80", "81", "1488"]
  #default = [0]
}

variable "name_project" {
  description = "Name of project which be placed in all the resources"
  default = "skiff"
}

provider "aws" {
  default_tags {
    tags = {
      Learning = "Terraform"
      Owner = "yaroslav.gankov"
      Creator = "yaroslav.gankov"
    }
  }
}

variable "vpc_cidr_mask16" {
  description = "Enter VPC CIDR/16 first two numbers (without dot in the end): Example: '10.171'"
}

variable "vpc_id" {
  description = "Enter desired VPC ID"
}

variable "sg_explain_word" {
  description = "Enter the word that explain the SG. Example for the 'public': 10.171.x.x.-public-skiff-dev"
  default = "custom"
}

resource "aws_security_group" "SG_skiff" {
  name        = "${var.vpc_cidr_mask16}.x.x-${var.sg_explain_word}-${var.name_project}-${var.env}"
  description = can("${index(var.port_to_open_in_sg,0)}") == true ? "local traffic" : join("+",var.port_to_open_in_sg)
  vpc_id      = var.vpc_id

  #inbound
  dynamic "ingress" {
    for_each = var.port_to_open_in_sg
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      #если в списке портов указан 0, то указываем все протоколы "-1"; в ином случае указываем "tcp"
      protocol    = can("${index(var.port_to_open_in_sg,0)}") == true ? "-1" : "tcp"
      #если в списке портов указан 0, то это private подсеть и в ней нужно разрешить трафик только от внутренних источников
      cidr_blocks = can("${index(var.port_to_open_in_sg,0)}") == true ? ["${var.vpc_cidr_mask16}.0.0/16"] : ["0.0.0.0/0"]
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
    Name    = "${var.vpc_cidr_mask16}.x.x-${var.sg_explain_word}-${var.name_project}-${var.env}"
  }
}

output "webserver_sg_id" {
  value = aws_security_group.SG_skiff.id
}