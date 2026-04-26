# sagemaker/registry_model.py
import boto3, os, tarfile

REGION     = "eu-west-3"
ACCOUNT_ID = "718100329950"
ENV        = "dev"
BUCKET     = f"mlops-expert-artifacts-{ENV}"
GROUP_NAME = f"SmartReviewModels-{ENV}"

# 1. Compresser le modèle
print("Compression du modèle...")
with tarfile.open("model.tar.gz", "w:gz") as tar:
    tar.add("model/baseline.pkl", arcname="model.pkl")
print("model.tar.gz créé ")

# 2. Uploader dans S3
print("Upload vers S3...")
s3 = boto3.client("s3", region_name=REGION)
s3.upload_file("model.tar.gz", BUCKET, "models/smartreview/model.tar.gz")
model_uri = f"s3://{BUCKET}/models/smartreview/model.tar.gz"
print(f"Modèle uploadé : {model_uri} ")

# 3. Enregistrer dans Model Registry
print("Enregistrement dans Model Registry...")
sm = boto3.client("sagemaker", region_name=REGION)

sm.create_model_package(
    ModelPackageGroupName=GROUP_NAME,
    ModelPackageDescription="SmartReview v1 — TF-IDF + LogisticRegression",
    ModelApprovalStatus="Approved",
    CustomerMetadataProperties={
        "model_uri":   model_uri,
        "framework":   "sklearn",
        "accuracy":    "0.9186",
        "environment": ENV,
    },
)
print(f"Modèle enregistré dans {GROUP_NAME} ")

# Nettoyer
os.remove("model.tar.gz")
print("Terminé ")