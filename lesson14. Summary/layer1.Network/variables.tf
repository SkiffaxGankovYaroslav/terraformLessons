#VARIABLES for VPC
variable vpc_cidr_mask16 {
    description = "First two numbers of the VPC (without dot in the end)"
    type = string
    default = "10.173"
}

variable count_subnets {
  description = "number of public subnets with mask /24 to create"
  default = 4
}

variable "count_subnets_internal" {
  description = "number of internal subnets with mask /24 to create"
  default = 0
}

variable "count_subnets_db" {
  description = "number of DB-subnets with mask /24 to create"
  default = 0
}

locals {
  vpc_cidr = "${var.vpc_cidr_mask16}.0.0/16"
}

#VARIABLES Common
variable "env" {
    description = "Define stage of development: dev, test, prod"
    default = "dev"
}

variable "name_project" {
  description = "Name of project which be placed in all the resources"
  default = "skiff"
}


#Какую VPC будем искать (по тегу). В какой сети будем создавать ресурсы
variable "name_of_VPC" {
  description = "name of VPC to find"
  type = string
  default = "10.0.x.x-main"
}

#Какие подсети будем искать. В каких сетях будем создавать ресурсы
#Используется в фильтре подсетей
variable "tag_of_subnets_to_find" {
  description = "subnets with specified tag"
  type = string
  default = "*external*"
}

variable "name_of_instance_type" {
  description = "Instance Type"
  type = string
  default = "t3.nano"
}

