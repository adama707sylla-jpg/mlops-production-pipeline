# sagemaker/deploy_endpoint.py
import boto3, os, json

REGION     = "eu-west-3"
ACCOUNT_ID = "718100329950"
ENV        = "dev"
BUCKET     = f"mlops-expert-artifacts-{ENV}"
ROLE       = f"arn:aws:iam::{ACCOUNT_ID}:role/mlops-expert-sagemaker-exec-{ENV}"
GROUP_NAME = f"SmartReviewModels-{ENV}"
ENDPOINT   = f"smartreview-endpoint-{ENV}"
MODEL_NAME = f"smartreview-model-{ENV}"
CONFIG     = f"smartreview-config-{ENV}"

sm  = boto3.client("sagemaker", region_name=REGION)
asg = boto3.client("application-autoscaling", region_name=REGION)

# 1. Récupérer la dernière version approuvée
print("Récupération du modèle approuvé...")
packages = sm.list_model_packages(
    ModelPackageGroupName=GROUP_NAME,
    ModelApprovalStatus="Approved",
    SortBy="CreationTime",
    SortOrder="Descending",
)["ModelPackageSummaryList"]

if not packages:
    raise Exception(f"Aucun modèle approuvé dans {GROUP_NAME}")

model_uri = packages[0]["CustomerMetadataProperties"]["model_uri"] \
    if "CustomerMetadataProperties" in packages[0] else None

print(f"Modèle trouvé : {packages[0]['ModelPackageArn']}")

# 2. Créer le modèle SageMaker avec image sklearn
YOUR_IMAGE = f"718100329950.dkr.ecr.eu-west-3.amazonaws.com/mlops-expert-api:v8"

# Supprimer l'ancien modèle si existe
try:
    sm.delete_model(ModelName=MODEL_NAME)
    print(f"Ancien modèle supprimé")
except:
    pass


sm.create_model(
    ModelName=MODEL_NAME,
    ExecutionRoleArn=ROLE,
    PrimaryContainer={
        "Image":        YOUR_IMAGE,
        "ModelDataUrl": f"s3://{BUCKET}/models/smartreview/model.tar.gz",
        "Environment": {
            "MODEL_PATH": "/opt/ml/model/model.pkl",
             "SAGEMAKER_BIND_TO_PORT": "8080",
        }
    },
)

print(f"Modèle créé : {MODEL_NAME}")

# 3. Créer endpoint config
try:
    sm.delete_endpoint_config(EndpointConfigName=CONFIG)
except:
    pass

sm.create_endpoint_config(
    EndpointConfigName=CONFIG,
    ProductionVariants=[{
        "VariantName":          "AllTraffic",
        "ModelName":            MODEL_NAME,
        "InstanceType":         "ml.t2.medium",
        "InitialInstanceCount": 1,
        "InitialVariantWeight": 1,
    }],
)
print(f"Config créée : {CONFIG}")

# 4. Créer ou mettre à jour l'endpoint
existing = [e["EndpointName"] for e in sm.list_endpoints()["Endpoints"]]

if ENDPOINT in existing:
    print(f"Mise à jour endpoint : {ENDPOINT}")
    sm.update_endpoint(EndpointName=ENDPOINT, EndpointConfigName=CONFIG)
else:
    print(f"Création endpoint : {ENDPOINT}")
    sm.create_endpoint(EndpointName=ENDPOINT, EndpointConfigName=CONFIG)

# 5. Attendre que l'endpoint soit prêt (5-10 min)
print("En attente de l'endpoint... (5-10 minutes)")
waiter = sm.get_waiter("endpoint_in_service")
waiter.wait(
    EndpointName=ENDPOINT,
    WaiterConfig={"Delay": 30, "MaxAttempts": 30}
)
print(f"Endpoint prêt : {ENDPOINT} ")

# 6. Auto-scaling
"""
resource_id = f"endpoint/{ENDPOINT}/variant/AllTraffic"

asg.register_scalable_target(
    ServiceNamespace="sagemaker",
    ResourceId=resource_id,
    ScalableDimension="sagemaker:variant:DesiredInstanceCount",
    MinCapacity=1,
    MaxCapacity=3,
)

asg.put_scaling_policy(
    PolicyName=f"{ENDPOINT}-scaling",
    ServiceNamespace="sagemaker",
    ResourceId=resource_id,
    ScalableDimension="sagemaker:variant:DesiredInstanceCount",
    PolicyType="TargetTrackingScaling",
    TargetTrackingScalingPolicyConfiguration={
        "TargetValue": 100.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "SageMakerVariantInvocationsPerInstance"
        },
        "ScaleInCooldown":  300,
        "ScaleOutCooldown": 60,
    },
)
"""
print("Auto-scaling configuré ")
print(f"\nEndpoint prêt à recevoir des requêtes : {ENDPOINT}")