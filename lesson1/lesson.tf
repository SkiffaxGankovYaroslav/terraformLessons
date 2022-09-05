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
}

#resource with user data from file
resource "aws_instance" "test-Terraform-skiff" {
  count         = 0
  ami           = "ami-08d4ac5b634553e16"
  instance_type = "t3.micro"
  #subnet_id и security group нужно указывать, если нет default VPC в указанном регионе
  vpc_security_group_ids = [aws_security_group.security_group1_skiff.id]
  subnet_id              = "subnet-0fad79be175865aa3"
  tags = {
    Name  = "terraform3-skiff"
    Owner = "yaroslav.gankov"
  }
  #здесь указан скрипт из файла
  #но если скрипт пишется не через файл (не этот случай), то в скрипте не должно быть пробелов и Tab в начале (без сдвига типа на Tab)
  user_data = file("user_data.sh")
}

#resource with user data from file-template
resource "aws_instance" "test-Terraform-skiff-dynamic" {
#  count         = 1
  ami           = "ami-08d4ac5b634553e16"
  instance_type = "t3.nano"
  #subnet_id и security group нужно указывать, если нет default VPC в указанном регионе
  vpc_security_group_ids = [aws_security_group.security_group1_skiff.id]
  subnet_id              = "subnet-0fad79be175865aa3"
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

resource "aws_security_group" "security_group1_skiff" {
  name        = "Webserver SG skiff"
  description = "SSH+HTTP+HTTPS"
  vpc_id      = "vpc-0f6aa5d4c120a0c42"
  #inbound
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "from_terraform_skiff"
    Creator = "yaroslav.gankov"
  }
}

# resource "aws_instance" "test-skiff-2" {
#     ami = "ami-08d4ac5b634553e16"
#     instance_type = "t3.micro"
#     vpc_security_group_ids = ["sg-03f717db8e33cd9bb"]
#     subnet_id = "subnet-0fad79be175865aa3"
#     tags = {
#         Name = "terraform2-skiff"
#         Owner = "yaroslav.gankov"
#     }
# }

#output values in the console after "terraform apply"
output "instance_id" {
  description = "ID of the instance"
  value = aws_instance.test-Terraform-skiff-dynamic.id
}

output "instance_public_ip" {
  description = "Public IP of this instance"
  value = aws_instance.test-Terraform-skiff-dynamic.public_ip
}