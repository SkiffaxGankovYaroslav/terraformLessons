terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Learning = "Terraform"
      Owner = "yaroslav.gankov"
      Creator = "yaroslav.gankov"
    }
  }
}

#resource with user data from file-template
resource "aws_instance" "instance-dynamic" {
#  count         = 1
  ami           = "ami-08d4ac5b634553e16"
  instance_type = "t3.nano"
  #subnet_id и security group нужно указывать, если нет default VPC в указанном регионе
  vpc_security_group_ids = [aws_security_group.security_group1_skiff.id]
  subnet_id              = "subnet-04c66bc3225e9a67a"
  tags = {
    Name  = "terraform4-skiff"
    Owner = var.owner_or_creator_name #using variable "owner_or_creator_name" from file "variables.tf"
  }
  #если загружается динамический файл, то используется template

  user_data = templatefile("user_data.sh.tpl", {
    f_name = "Skiff" #использование переменной ${f_name}
    l_name = "Family"
    names  = ["Vasya", "Kolya", "Petya", "Masha"]
  })
}

# #allocate and bind Elastic IP Address
# resource "aws_eip" "skiff_static_ip" {
#   instance = aws_instance.instance-dynamic.id
# }

resource "aws_security_group" "security_group1_skiff" {
  name        = "Webserver SG skiff"
  description = "SSH+HTTP+HTTPS"
  vpc_id      = "vpc-0465e4ae2df3296b3"

  #inbound
  dynamic "ingress" {
    for_each = ["443", "22", "80","1488"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  #outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #all the protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "from_terraform_skiff"
    Creator = "yaroslav.gankov"
  }
}

#output values in the console after "terraform apply"
output "instance_id" {
  description = "ID of the instance"
  value = aws_instance.instance-dynamic.id
}

output "instance_public_ip" {
  description = "Public IP of this instance"
  value = aws_instance.instance-dynamic.public_ip
}

# lifecycle {
#   prevent_destroy = true
# #  ignore_changes = [ "ami", "user_data" ]
# # create_before_destroy = true
# }