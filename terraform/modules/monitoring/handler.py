# terraform/modules/monitoring/handler.py

import json, boto3, os

def lambda_handler(event, context):
    """
    Lambda function to handle CloudWatch alarms and send notifications to SNS topic.
    """
    pipeline_name = os.environ['PIPELINE_NAME']
    sm = boto3.client("sagemaker")

    response = sm.start_pipeline_execution(
        PipelineName=pipeline_name,
        PipelineExecutionDisplayName="auto-retarin-drift-detected"
    )

    print(f"pipeline relance : {response['PipelineExecutionArn']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Pipeline triggered!')
    }
