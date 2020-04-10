variable "azure_resource_group_name" {
  type = string
}

variable "azure_location" {
  type = string
}

variable "azure_vm_size" {
  type = string
}

variable "azure_vm_tags" {
  type    = map(string)
  default = {}
}

variable "num_instances" {
  type = string
  default = 1
}

variable "azure_vm_admin_username" {
  type = string
}

variable "azure_vm_admin_password" {
  type = string
}