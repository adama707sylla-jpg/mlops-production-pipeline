output "bucket_name" {
  value = module.sagemaker.bucket_name
}

output "sagemaker_role_arn" {
  value = module.sagemaker.sagemaker_role_arn
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
