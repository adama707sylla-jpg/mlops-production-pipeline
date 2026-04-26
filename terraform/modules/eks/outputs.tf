# terraform/modules/eks/outputs.tf

output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "URL de l'API server Kubernetes"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca" {
  description = "Certificate Authority du cluster — pour kubectl"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

