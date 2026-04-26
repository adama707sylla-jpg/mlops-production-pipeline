terraform {
  backend "s3" {
    bucket         = "mlops-expert-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "mlops-expert-tf-lock"
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "sagemaker" {
  source       = "../../terraform/modules/sagemaker"
  environment  = "dev"
  bucket_name  = "mlops-expert-artifacts"
  project_name = "mlops-expert"
}

module "eks" {
  source        = "../../terraform/modules/eks"
  cluster_name  = "mlops-dev"
  instance_type = "t3.small"  # ← Free Tier eligible
  min_nodes     = 1
  max_nodes     = 2
}

module "monitoring" {
  source                  = "../../terraform/modules/monitoring"
  environment             = "dev"
  project_name            = "mlops-expert"
  alarm_email             = "adama@email.com"
  drift_threshold         = 0.3
  sagemaker_endpoint_name = "smartreview-endpoint-dev"
} 


module "github_oidc" {
  source      = "../../terraform/modules/github_oidc"
  environment = "dev"
  github_repo = "adama707sylla-jpg/mlops-production-pipeline"
}

output "github_actions_role_arn" {
  value = module.github_oidc.github_actions_role_arn
}