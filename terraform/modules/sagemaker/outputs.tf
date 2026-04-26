# les outputs sont les valeurs que le module expose a l'exterieur pour etre utilisees par d'autres modules ou ressources
# Des valeurs crees par ce module

output "bucket_name" {
  value       = aws_s3_bucket.ml_artifacts.id
  description = "Nom du bucket S3  ML"
}

output "bucket_arn" {
  description = "ARN du bucket utile pour les policies IAM"
  value       = aws_s3_bucket.ml_artifacts.arn
}

output "sagemaker_role_arn" {
  description = "ARN du role IAM pour SageMaker passe du training job"
  value       = aws_iam_role.sagemaker_exec.arn
}

output "model_package_role_arn" {
  description = "Nom du groupe model registry"
  value       = aws_sagemaker_model_package_group.models.model_package_group_name

}