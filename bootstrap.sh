# bootstrap.sh a lancer une seule fois 
#!/bin/bash

AWS_REGION=eu-west-3
BUCKET_NAME="mlops-expert-tfstate"
TABLE_NAME="mlops-expert-tf-lock"

# Créer le bucket S3 pour stocker les fichiers d'état de Terraform
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION

#Activer le versioning sur le bucket S3 nous permettra de conserver un historique des modifications du fichier d'état de Terraform, ce qui est crucial pour la récupération en cas de problème.
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled


#Bloquer les accès public au bucket S3
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,\
    BlockPublicPolicy=true,RestrictPublicBuckets=true

# Créer la table DynamoDB pour le verrouillage de Terraform
aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_REGION

echo "Bootstrap completed successfully!"    
