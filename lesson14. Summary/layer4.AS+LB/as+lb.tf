#----------------------------------------------------------------------
# Refresh intances in AutoScaling Group following blue-green deployment
# Create:
#   - Security Group
#   - Launch Configuration with auto AMI-Ubuntu lookup
#   - AutoScaling Group
#   - Application Load Balancer.
# Find VPC with specified name, find subnets with tag "*external*" and..
# ..create all the above resources in it
#
# Modified by Skiff
#----------------------------------------------------------------------

# provider "aws" {
#   region = "us-east-1"
# }

#read availability zones in our region
# data "aws_availability_zones" "available_zones" {}
#search for latest ubuntu image
data "aws_ami" "latest_ubuntu" {
  owners = ["amazon"]
  most_recent = true #latest
  #filter all images with owner "amazon" by name that below
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64*"] #part of the AMI-name
  }
}

# data "aws_vpc" "searchingVPC" {
#   #filter for VPC results
#   tags = {
#     Name = var.name_of_VPC
#   }
# }


# #находим external subnets в искомой сети VPC по тегу
# data "aws_subnets" "ext_subnet" {
#   filter {
#     name = "vpc-id"
#     values = [data.aws_vpc.searchingVPC.id]
#   }
#   filter {
#     name = "tag:Name"
#     values = [var.tag_of_subnets_to_find]
#   }
# }

variable "current_subnets_id" {
  
}

variable "current_VPC_id" {
  
}

variable "sg_ids" {
  
}

variable "file_for_user_data" {
    description = "Specify path ot file with user data. Default: 'user_data.sh'"
    default = "user_data.sh"
}

# #create security group
# resource "aws_security_group" "security_group1_skiff" {
#   name        = "Webserver SG skiff"
#   description = "SSH+HTTP+HTTPS"
#   vpc_id      = var.current_VPC_id

#   #inbound
#   dynamic "ingress" {
#     for_each = var.port_to_open_in_sg
#     content {
#       from_port   = ingress.value
#       to_port     = ingress.value
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["10.10.0.0/16"]
#   }

#   #outbound
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" #all the protocols
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name    = "from_terraform_skiff"
#     Creator = var.owner_or_creator_name
#   }
# }

#create launch configuration
resource "aws_launch_configuration" "simple_webserver" {
  #name = "terraform_skiff"
  name_prefix = "terraform-skiff"
  image_id = data.aws_ami.latest_ubuntu.id
  instance_type = var.name_of_instance_type
  security_groups = [var.sg_ids]
  user_data = file(var.file_for_user_data)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "simple_autoscale" {
  #name                      = "TerForm-Skiff-${aws_launch_configuration.simple_webserver.name}"
  name                      = "TerForm-Skiff"
  max_size                  = 5
  desired_capacity          = 3
  min_size                  = 2
  #min_elb_capacity          = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  #force_delete              = true
  #placement_group           = aws_placement_group.test.id
  launch_configuration      = aws_launch_configuration.simple_webserver.name
  vpc_zone_identifier       = var.current_subnets_id
  
  #with application LB use target_group_arns
  target_group_arns = [aws_lb_target_group.simple_elb.arn]
  
  # #variant1 to place the tags
  # tags = [
  #   {
  #     key = "Name"
  #     value = "terraform_skiff_server"
  #     propagate_at_launch = true
  #   },
  #   {
  #     key = "Owner"
  #     value = var.owner_or_creator_name
  #     propagate_at_launch = true
  #   },
  # ]

  #variant2 to place the tags (dynamic)
  dynamic "tag" {
    for_each = var.common_tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = {
      Name = "terraform_skiff_server"
    }
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup = 65
    }
    triggers = ["tag"]
  }

#   initial_lifecycle_hook {
#     name                 = "foobar"
#     default_result       = "CONTINUE"
#     heartbeat_timeout    = 2000
#     lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

#     notification_metadata = <<EOF
# {
#   "foo": "bar"
# }
# EOF

#     notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
#     role_arn                = "arn:aws:iam::123456789012:role/S3Access"
#   }
  
}

#application load balancer
resource "aws_lb" "simple_elb" {
  name = "terraform-ELB"
  load_balancer_type = "application"
  subnets = var.current_subnets_id
  security_groups = [sg_ids]
  tags = {
    Name = "terraform-elb-skiff"
    Creator = var.owner_or_creator_name
  }
}
resource "aws_lb_target_group" "simple_elb" {
  name     = "terraform-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = current_VPC_id
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

output "web_loadbalancer_url" {
  value = aws_lb.simple_elb.dns_name
}