#--------VARIABLES
variable "temp_vpc_cidr_mask16" {
  description = "First two numbers of the VPC (without dot in the end). Example: '10.178'"
  default = "10.171"
}

variable "name_project" {
  description = "Name of project which be placed in all the resources"
  default = "skiff3"
}


#--------MAIN
provider "aws" {
  default_tags {
    tags = {
      Learning = "Terraform"
      Owner = "yaroslav.gankov"
      Creator = "yaroslav.gankov"
    }
  }
}

module "create_skiff_VPC_and_subnets" {
  # MODULE create_skiff_VPC_and_subnets:
  # DESCRIPTION: Create VPC+subnets+IGateway+RouteTable
  # OUTPUTS:
  # vpc_id
  # vpc_cidr
  # public_subnet_ids
  # internal_subnet_ids
  # DB_subnet_ids
  # vpc_cidr_mask16 - first two numbers of CIDR/16, example "10.171"
  source = "./layer1.Network" 
  count_subnets = 2 #number of public subnets in VPC with Internet Gateway
  count_subnets_internal = 2 #number of internal subnets in VPC with NAT
  count_subnets_db = 2 #number of DB subnets in VPC
  vpc_cidr_mask16 = var.temp_vpc_cidr_mask16 #first two numbers of CIDR/16, example "10.171"
  name_project = var.name_project
}

module "create_SG_public" {
    source = "./layer2.SG" 
    vpc_cidr_mask16 = module.create_skiff_VPC_and_subnets.vpc_cidr_mask16
    vpc_id = module.create_skiff_VPC_and_subnets.vpc_id
    port_to_open_in_sg = ["22","80","8080","8081"] #list of ports to open, example ["443", "22", "80"]
    sg_explain_word = "public"
    name_project = var.name_project
}

module "create_SG_private" {
    source = "./layer2.SG" 
    vpc_cidr_mask16 = module.create_skiff_VPC_and_subnets.vpc_cidr_mask16
    vpc_id = module.create_skiff_VPC_and_subnets.vpc_id
    port_to_open_in_sg = [0] #list of ports to open, example ["443", "22", "80"]; if [0] then SG will be private (with local-traffic)
    sg_explain_word = "private"
    name_project = var.name_project
}

module "create_SG_for_LB" {
    source = "./layer2.SG" 
    vpc_cidr_mask16 = module.create_skiff_VPC_and_subnets.vpc_cidr_mask16
    vpc_id = module.create_skiff_VPC_and_subnets.vpc_id
    port_to_open_in_sg = ["80"] #list of ports to open, example ["443", "22", "80"]; if [0] then SG will be private (with local-traffic)
    sg_explain_word = "ForLB"
    name_project = var.name_project
}

# CREATE INSTANCES
module "create_simple_public_instance" {
  source = "./layer3.Servers"
  number_of_servers = 4
  file_for_user_data = "user_data1.sh"
  subnet_ids = module.create_skiff_VPC_and_subnets.public_subnet_ids
  sg_id = [module.create_SG_public.webserver_sg_id]
  server_name = "${var.name_project}-public"
}
# #internet by NAT
# module "create_simple_private_instance" {
#   source = "./layer3.Servers"
#   number_of_servers = 2
#   file_for_user_data = "user_data1.sh"
#   subnet_ids = module.create_skiff_VPC_and_subnets.internal_subnet_ids
#   sg_id = [module.create_SG_private.webserver_sg_id]
#   server_name = "${var.name_project}-private"
#   key_pair_name = "RSA_skiff"
# }
# #no_internet
# module "create_simple_DB_instance" {
#   source = "./layer3.Servers"
#   number_of_servers = 2
#   file_for_user_data = "user_data1.sh"
#   subnet_ids = module.create_skiff_VPC_and_subnets.DB_subnet_ids
#   sg_id = [module.create_SG_private.webserver_sg_id]
#   server_name = "${var.name_project}-DB"
#   key_pair_name = "RSA_skiff"
# }

module "create_lb_for_instances" {
  # description: create LB and attach specific instances to it. Instances must be created in another module
  # Variables:
  # id_aws_instances - tuple of instances' IDs, which need to be attached
  # current_subnets_id - IDs of the subnets, where LB will be created
  # sg_ids - SecurityGroups IDs to LB
  source = "./layer4.LB"
  id_aws_instances = module.create_simple_public_instance.id_aws_instances
  current_VPC_id = module.create_skiff_VPC_and_subnets.vpc_id
  current_subnets_id = module.create_skiff_VPC_and_subnets.public_subnet_ids
  sg_ids = [module.create_SG_for_LB.webserver_sg_id]
}

#--------OUTPUT
output "web_loadbalancer_url" {
  value = module.create_lb_for_instances.web_loadbalancer_url
}


# module "autoscale+load_balancer" {
#   source = "./layer4.AS+LB"
#   current_subnets_id = module.create_skiff_VPC_and_subnets.public_subnet_ids
#   current_VPC_id = module.create_skiff_VPC_and_subnets.vpc_id
#   sg_ids = module.create_SG_public.webserver_sg_id
# }

# output "output_public_subnet_ids" {
#   value = module.create_skiff_VPC_and_subnets.public_subnet_ids
# }

# output "id_servers" {
#   value = module.create_simple_public_instance.id_aws_instances
# }