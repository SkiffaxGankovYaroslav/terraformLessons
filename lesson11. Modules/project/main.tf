#--------------------------------------
#project
#--------------------------------------

module "create_instance_module" {
  # #example with local path
  # source = "../modules" 
  #example with git repository
  source = "git@github.com:YaroslavGankov/training-terraform.git//LearningModules_CreateCustomNetwork"
  #override some module's variables
  public_subnets_cidrs = [
        "10.173.1.0/24",
        "10.173.2.0/24",
        "10.173.3.0/24",
        "10.173.4.0/24",
    ] 
}


#output подключается к модулю и может выборочно отображать output из модуля. Output отсюда отображает output, которые есть в модуле
output "vpc_subnetsID_output" {
  value = module.create_instance_module
}