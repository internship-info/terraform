//provider "aws" {
//  region                  = "eu-central-1"
//  shared_credentials_file = "/home/cruntov/.aws/credentials"
//  profile                 = "TCD"
//}

#################################################
#                                               #
#            Variables Section Start            #
#                                               #
#################################################

################################################
# List variables
################################################
variable "list_strings" {
  type    = list(string)
  default = ["elena", "ana", "vlad", "ana"]
}
output "list_strings" {
  value = var.list_strings
}

variable "list_numbers" {
  type    = list(number)
  default = [10, 1, 0, -1]
}
output "list_numbers" {
  value = var.list_numbers
}

# Usage
resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  security_group_id = "sg-12345"
}

resource "aws_iam_user" "example" {
  name = var.list_strings[2]
}

################################################
# Set variables
################################################
variable "set_strings" {
  type    = set(string)
  default = ["elena", "ana", "vlad", "ana"]
}
output "set_strings" {
  value = var.set_strings
}

variable "set_numbers" {
  type    = set(number)
  default = [10, 1, 0, -1]
}

# Usage
output "set_numbers" {
  value = var.set_numbers
}
resource "aws_iam_user" "example" {
  name = var.set_strings[2]
}

################################################
# Map variables
################################################
variable "map0" {
  type = map(string)
  default = {
    us-east-1a = "10.0.1.0/24"
    us-east-1b = "10.0.2.0/24"
    us-east-1c = "10.0.3.0/24"
  }
}
variable "map1" {
  type = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
    "us-east-1c" = "10.0.3.0/24"
  }
}

variable "map2" {
  type = map(number)
  default = {
    from_port = 0
    to_port   = 10
  }
}

variable "map3" {
  type = map(number)
  default = {
    "from_port" = 0
    "to_port"   = 10
  }
}

# Usage
resource "aws_security_group_rule" "example" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = var.map3.from_port
  to_port           = var.map2.to_port
  cidr_blocks       = [var.map0[var.region], var.map1[var.region]]
  security_group_id = "sg-1234"
}
################################################
# Tuple variables
################################################
variable "tuple_var" {
  type    = tuple([number, string, bool])
  default = [100, "constantin", true]
}

# Usage
output "tuple_output" {
  value = var.tuple_var
}

#################################################
#                                               #
#            Variables Section End              #
#                                               #
#################################################
