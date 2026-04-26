# terraform/modules/eks/variables.tf

variable "cluster_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 3
}