#----------------------------------------------------------------------
# Modified by Skiff
#----------------------------------------------------------------------

variable "current_subnets_id" {
  
}

variable "current_VPC_id" {
  
}

variable "sg_ids" {
  
}

variable "name_project" {
  description = "Name of project which be placed in all the resources"
  default = "skiff"
}

variable "id_aws_instances" {
  
}

#application load balancer
resource "aws_lb" "simple_elb" {
  name = "${var.name_project}-ELB"
  load_balancer_type = "application"
  subnets = var.current_subnets_id
  security_groups = var.sg_ids
  tags = {
    Name = "${var.name_project}-ELB"
  }
}
resource "aws_lb_target_group" "simple_elb" {
  name     = "${var.name_project}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.current_VPC_id
}
resource "aws_lb_listener" "simple_elb" {
  load_balancer_arn = aws_lb.simple_elb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.simple_elb.arn
  }
}
resource "aws_lb_target_group_attachment" "attach_instances" {
  count = length(var.id_aws_instances)
  target_group_arn = aws_lb_target_group.simple_elb.arn
  target_id        = var.id_aws_instances[count.index]
  port             = 80
}

output "web_loadbalancer_url" {
  value = aws_lb.simple_elb.dns_name
}