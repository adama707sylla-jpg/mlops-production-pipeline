# terraform/modules/sagemaker/variables.tf

variable "environment" {
  description = "dev ou prod"
  type        = string
}

variable "bucket_name" {
  description = "Nom du bucket S3"
  type        = string
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "mlops-expert"
}

variable "model_package_group" {
  description = "Nom du groupe Model Registry"
  type        = string
  default     = "SmartReviewModels"
}