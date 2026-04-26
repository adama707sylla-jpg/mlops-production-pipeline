terraform {
  backend "s3" {
    bucket         = "mlops-expert-tfstate"
    key            = "prod/terraform.tfstate"
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
  environment  = "prod"
  bucket_name  = "mlops-expert-artifacts"
  project_name = "mlops-expert"
}

module "eks" {
  source        = "../../terraform/modules/eks"
  cluster_name  = "mlops-prod"
  instance_type = "t3.medium"
  min_nodes     = 1
  max_nodes     = 3
}

module "monitoring" {
  source                  = "../../terraform/modules/monitoring"
  environment             = "prod"
  project_name            = "mlops-expert"
  alarm_email             = "adama@email.com"
  drift_threshold         = 0.15
  sagemaker_endpoint_name = "smartreview-endpoint-prod"
}