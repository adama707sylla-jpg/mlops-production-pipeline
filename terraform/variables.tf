# terraform/variables.tf  variables globales partagées entre les modules

variable "aws_region" {
  description = "Region AWS"
  type = string
  default = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet - prefix pour les ressources AWS"
  type = string
  default = "mlops-expert"
}



