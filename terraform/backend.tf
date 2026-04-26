#Pas de stockage en local mais en s3
terraform {

  backend "s3" {
    bucket  = "mlops-expert-tfstate"
    key     = "global/terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true

    #Dynamo pour le verou empeche deux terraform simultanes
    dynamo_table = "mlops-expert-tf-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "-> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}
