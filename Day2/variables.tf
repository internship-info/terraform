variable "prefix" {
  type        = string
  default     = "internship-info"
  description = "This prefix will be included in the name of most resources."
}

variable "region" {
  default = "us-east-1a"
}

variable "vpc_id" {
  default = "vpc-1234"
}

variable "default_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}