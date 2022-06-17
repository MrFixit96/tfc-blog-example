variable "aws_region" {
  type    = string
}

variable "aws_key_pair" {
  type    = string
}

variable "aws_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "aws_instance_tags" {
  type    = map(string)
  default = {}
}

variable "num_instances" {
  type    = string
  default = 1
}

