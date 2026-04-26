# terraform/modules/monitoring/variables.tf

variable "environment" {
  type = string
}

variable "project_name" {
  type    = string
  default = "mlops-expert"
}

variable "alarm_email" {
  description = "Email qui reçoit les alertes drift"
  type        = string
}

variable "drift_threshold" {
  description = "Seuil de drift pour déclencher l'alarme"
  type        = number
  default     = 0.2
}

variable "sagemaker_endpoint_name" {
  description = "Nom de l'endpoint SageMaker à monitorer"
  type        = string
}