#блок для считывания данных из файла состояния
data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
        bucket="bucket-from-lambda-skiff"
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}

#блок для записи данных из файла состояния. Обязательно нужно, чтобы файл отличался от предыдущего файла, с которого брали состояние
terraform {
  backend "s3" {
    bucket="bucket-from-lambda-skiff"
    key = "layer2/terraform.tfstate"
    region = "us-east-1"
  }
}

output "network_details" {
    value = data.terraform_remote_state.network
}

resource "aws_security_group" "SG_skiff" {
  name        = "Webserver SG skiff"
  description = "SSH+HTTP+HTTPS"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  #inbound
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
    creator = "yaroslav.gankov"
    learning = "Terraform"
  }
}

output "webserver_sg_id" {
  value = aws_security_group.SG_skiff.id
}