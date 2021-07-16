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
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))

  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.2.0/24"]
    }
  ]
}

# Used
resource "aws_security_group" "ssh-http" {
  name   = "ssh-http"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_group
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
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
  name        = "lb-target-group"
  port        = "8080"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200,301,302"
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
  name  = "neo.${count.index}"
}

# Second example

// This is just pseudo-code, it won't work in Terraform
// for(i=0;i<3;i++){
//   resource "aws_iam_user" "example" {
//     name = vars.users_list[i]
//   }
// }

variable "users_list" {
  type    = list(string)
  default = ["vlad", "constantin", "egor"]
}
resource "aws_iam_user" "example" {
  count = length(var.users_list)
  name  = var.users_list[count.index]
}

################################################
# for-each
################################################

# for_each on resources with a list
variable "user_names0" {
  type    = list(string)
  default = ["vlad", "constantin", "egor"]
}
resource "aws_iam_user" "example" {
  for_each = toset(var.user_names0)
  name     = each.value
}

# for_each on resources with a set
variable "user_names1" {
  type    = set(string)
  default = ["vlad", "constantin", "egor"]
}
resource "aws_iam_user" "example" {
  for_each = var.user_names1
  name     = each.value
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
  for_each          = var.subnets_map
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = each.key
}

#=================================================

# for_each resource with a map of objects
variable "instances_map" {
  type = map(object({
    ami                 = string
    instance_type       = string
    associate_public_ip = bool
  }))

  default = {
    artifactory = {
      ami                 = "ami-0e2b68f7b98b92c69"
      instance_type       = "t3.small"
      associate_public_ip = false
    }
    jenkins = {
      ami                 = "ami-0e2b68f7b98b92c69"
      instance_type       = "t3.small"
      associate_public_ip = true
    }

  }
}
resource "aws_instance" "this" {
  for_each                    = var.instances_map
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  associate_public_ip_address = each.value.associate_public_ip
  tags                        = { Name = each.key }
}

# for_each resource with a list of objects
variable "instances_list" {
  type = list(object({
    ami                 = string
    instance_type       = string
    associate_public_ip = bool
  }))

  default = [
    {
      name                = "artifactory"
      ami                 = "ami-0e2b68f7b98b92c69"
      instance_type       = "t3.small"
      associate_public_ip = false
    },
    {
      name                = "jenkins"
      ami                 = "ami-0e2b68f7b98b92c69"
      instance_type       = "t3.small"
      associate_public_ip = true
    }
  ]
}
resource "aws_instance" "this" {
  for_each                    = { for vm in var.instances_list : vm.name => vm }
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  associate_public_ip_address = each.value.associate_public_ip
  tags                        = { Name = each.value.name }
}

#=================================================

# Intro
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_cidr_block]
  }

  tags = { Name = "allow_tls" }
}

# for_each inline block with a list
variable "customer_cidrs_list" {
  type = list(string)
  default = [
    "89.149.124.110/32", "89.149.124.111/32",
    "89.149.124.112/32"
  ]
}

resource "aws_security_group" "customer_sg" {
  name   = "customer_sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.customer_cidrs_list
    content {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_cidr_block]
  }
  tags = { Name = "customer_sg" }
}

# for_each inline block with a map
variable "customer_cidrs_map" {
  type = map(string)
  default = {
    "89.149.124.110/32" = "8443",
    "89.149.124.111/32" = "8555",
    "89.149.124.112/32" = "8663"
  }
}

resource "aws_security_group" "customer_sg" {
  name   = "customer_sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.customer_cidrs_map
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [ingress.key]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_cidr_block]
  }
  tags = { Name = "customer_sg" }
}

# for_each on inline block with a list of objects
variable "sg_list" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))

  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.2.0/24"]
    }
  ]
}
resource "aws_security_group" "ssh_http" {
  name   = "ssh_http"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_list
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

#################################################
#                                               #
#               Loops Section End               #
#                                               #
#################################################