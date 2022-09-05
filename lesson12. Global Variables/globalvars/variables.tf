#--------------------------------------------
#example of using global variables from s3
#push variables to s3
#variables can be pulled from s3 to another *.tf
#--------------------------------------------

#directive for remote-state-file storage for terraform
terraform {
  backend "s3" {
    bucket="bucket-from-lambda-skiff"
    key = "globalvars/terraform.tfstate"
    region = "us-east-1"
  }
}

output "company_name" {
  value = "Ardas"
}

output "owner_name" {
  value = "skiff"
}