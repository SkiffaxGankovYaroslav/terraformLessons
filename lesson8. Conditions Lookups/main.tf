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


resource "aws_instance" "skiff_webserver1" {
  ami = "ami-052efd3df9dad4825"
  instance_type = var.env == "prod" ? "t3.small" : "t3.nano"

  tags = {
      Name = "TerFormCond_skiff"
      owner = "yaroslav.gankov"
      var_owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
      Learning = "Terraform"
  }
  # dynamic "tags" {
  #   for_each = {
  #     Name = "TerFormCond_skiff"
  #     owner = "yaroslav.gankov"
  #     Learning = "Terraform"
  #   }
  #   content {
  #     key = tag.key
  #     value = tag.value
  #     propagate_at_launch = true
  #   }
  # }

}

resource "aws_instance" "skiff_webserver1_test" {
  count = var.env == "prod" ? 0 : 1
  ami = "ami-052efd3df9dad4825"
  instance_type = var.env == "prod" ? "t3.small" : "t3.nano"

  tags = {
      Name = "TerFormCond_skiff_test"
      owner = "yaroslav.gankov"
      #var_owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
      Learning = "Terraform"
  }
  # dynamic "tags" {
  #   for_each = {
  #     Name = "TerFormCond_skiff"
  #     owner = "yaroslav.gankov"
  #     Learning = "Terraform"
  #   }
  #   content {
  #     key = tag.key
  #     value = tag.value
  #     propagate_at_launch = true
  #   }
  # }

}

#instance with lookup
resource "aws_instance" "skiff_webserver1_lookup" {
  ami = "ami-052efd3df9dad4825"
  instance_type = lookup(var.instance_size, var.env)
  tags = {
      Name = "TerFormLookup_skiff"
      owner = "yaroslav.gankov"
      var_owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
      Learning = "Terraform"
  }
}