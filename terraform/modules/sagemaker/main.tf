

resource "aws_s3_bucket" "ml_artifacts" {
  bucket = "${var.bucket_name}-${var.environment}" # ← environment sans accent
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "ml_artifacts" {
  bucket = aws_s3_bucket.ml_artifacts.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "ml_artifacts" {
  bucket                  = aws_s3_bucket.ml_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "folders" {
  for_each = toset(["data/raw/", "data/processed/", "models/", "monitor/baseline/"])
  bucket   = aws_s3_bucket.ml_artifacts.id
  key      = each.value
  content  = ""
}

resource "aws_iam_role" "sagemaker_exec" {
  name = "${var.project_name}-sagemaker-exec-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sagemaker.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = {
    Project     = var.project_name
    Environment = var.environment # ← corrigé
  }
}

resource "aws_iam_role_policy_attachment" "sagemaker_full" {
  role       = aws_iam_role.sagemaker_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full" {
  role       = aws_iam_role.sagemaker_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.sagemaker_exec.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_sagemaker_model_package_group" "models" {
  model_package_group_name        = "${var.model_package_group}-${var.environment}"
  model_package_group_description = "Versions du modèle SmartReview — ${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}