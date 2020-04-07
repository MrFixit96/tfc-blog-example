variable "gcp_region" {
  type    = string
}

variable "gcp_region_zone" {
  type    = string
}

variable "gcp_project_name" {
  type = string
}

variable "gcp_instance_machine_type" {
  type = string
}

variable "gcp_instance_name" {
  type = string
}

variable "gcp_instance_tags" {
  type = list
  default = []
}

variable "num_instances" {
  type = "string"
  default = 1
}


