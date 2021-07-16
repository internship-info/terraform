#################################################
#                                               #
#            Variables Section Start            #
#                                               #
#################################################

################################################
# Object variables
################################################
variable "security_group" {
  type = list(object({
    port = number
    protocol = string
    cidr_blocks = list(string)
  }))

  default = [
    {
      port = 22
      protocol = "tcp"
      cidr_blocks = [ "10.0.1.0/24" ]
    },
    {
      port = 80
      protocol = "tcp"
      cidr_blocks = [ "10.0.2.0/24" ]
    }
  ]
}

# Used
resource "aws_security_group" "ssh-http" {
  name = "ssh-http"
  vpc_id = var.vpc

  dynamic "ingress" {
    for_each = var.security_group
    content {
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
#################################################
#                                               #
#             Variables Section End             #
#                                               #
#################################################

#################################################
#                                               #
#              Loops Section Start              #
#                                               #
#################################################

# Intro
resource "aws_lb_target_group" "lb_target_group" {
  name = "lb-target-group"
  port = "8080"
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = var.vpc

  health_check {
    path = "/"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 10
    interval = 30
    matcher = "200,301,302"
  }
}

################################################
# Count
################################################

# First example
// This is just pseudo-code, it won't work in Terraform
// for(i=0;i<3;i++){
//   resource "aws_iam_user" "example" {
//     name = "neo.${i}"
//   }
// }

resource "aws_iam_user" "example" {
  count = 3
  name = "neo.${count.index}"
}

# Second example

// This is just pseudo-code, it won't work in Terraform
// for(i=0;i<3;i++){
//   resource "aws_iam_user" "example" {
//     name = vars.users_list[i]
//   }
// }

variable "users_list" {
  type = list(string)
  default = ["vlad", "constantin", "egor"]
}
resource "aws_iam_user" "example" {
  count = length(var.users_list)
  name = var.users_list[count.index]
}

################################################
# for-each
################################################

# for_each on resources with a list
variable "user_names0" {
  type = list(string)
  default = [ "vlad", "constantin", "egor" ]
}
resource "aws_iam_user" "example" {
  for_each = toset(var.user_names0)
  name = each.value
}

# for_each on resources with a set
variable "user_names1" {
  type = set(string)
  default = [ "vlad", "constantin", "egor" ]
}
resource "aws_iam_user" "example" {
  for_each = var.user_names1
  name = each.value
}

# for_each on resources with a map
variable "subnets_map" {
  type = map(string)
  default = {
    us-east-1a = "10.0.1.0/24"
    us-east-1b = "10.0.2.0/24"
    us-east-1c = "10.0.3.0/24"
  }
}
resource "aws_subnet" "example" {
  for_each = var.subnets_map
  vpc_id = var.vpc
  cidr_block = each.value
  availability_zone = each.key
}


#################################################
#                                               #
#               Loops Section End               #
#                                               #
#################################################