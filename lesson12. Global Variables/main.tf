#--------------------------------------------
#example of using global variables from s3
#variables was pushed to s3 to terraform-output and now we can read it
#--------------------------------------------

#блок для считывания данных из файла состояния. Считываем отсюда все данные, потом из них извлекаем нужные переменные
data "terraform_remote_state" "global_vars" {
    backend = "s3"
    config = {
        bucket="bucket-from-lambda-skiff"
        key = "globalvars/terraform.tfstate"
        region = "us-east-1"
    }
}


#local variables
#turn global variables from data to convenient locals variables
locals {
    company_name1 = data.terraform_remote_state.global_vars.outputs.company_name
    owner_name1 = data.terraform_remote_state.global_vars.outputs.owner_name
}

#создаём ресурс с использованием глобальных переменных, взятых с S3
resource "aws_vpc" "vpc1" {
  cidr_block = "10.175.0.0/16"
  tags = {
    Name = "test-skiffVPC"
    Company = local.company_name1
    Owner = local.owner_name1
  }
}

# #for debug
# output "all_global_vars" {
#     value = data.terraform_remote_state.global_vars
# }