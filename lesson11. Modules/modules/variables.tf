variable "owner_or_creator_name" {
  description = "Name of the owner or of the creator"
  type        = string
  default     = "yaroslav.gankov"
}

# #какую VPC будем искать (по тегу). В какой сети будем создавать ресурсы
# variable "name_of_VPC" {
#   description = "name of VPC to find"
#   type = string
#   default = "10.0.x.x-main"
# }

#Какие подсети будем искать. В каких сетях будем создавать ресурсы
#Используется в фильтре подсетей
# variable "tag_of_subnets_to_find" {
#   description = "subnets with specified tag"
#   type = string
#   default = "*external*"
# }

# variable "name_of_instance_type" {
#   description = "Instance Type"
#   type = string
#   default = "t3.nano"
# }

# #which ports must be opened (allowed) in the server
# variable "port_to_open_in_sg" {
#   description = "list of opened ports in the server"
#   type = list
#   default = ["443", "22", "80", "81", "1488"]
# }

# variable "common_tags" {
#   description = "default tags such owner, project, learning..."
#   type = map
#   default = {
#     Owner = "yaroslav.gankov"
#     learning = "Terraform"
#   }
# }