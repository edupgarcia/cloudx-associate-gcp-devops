#!/bin/bash

# Get the secret value to pass as environment variable
SECRET_VALUE=$(gcloud secrets versions access latest --secret=$SECRET_NAME)

# Deploy Cloud Function (Gen 2)
gcloud functions deploy $FUNCTION_NAME \
    --gen2 \
    --runtime=python311 \
    --region=$REGION \
    --source=../../tasks/dynamic-serverless-website \
    --entry-point=$FUNCTION_ENTRY_POINT \
    --trigger-http \
    --allow-unauthenticated \
    --vpc-connector=$CONNECTOR_NAME \
    --egress-settings=private-ranges-only \
    --set-secrets=DB_CREDS=$SECRET_NAME:latest

# Get the function URL
FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME \
    --region=$REGION \
    --gen2 \
    --format="value(serviceConfig.uri)")

echo "Cloud Function deployed successfully"
echo "Function URL: $FUNCTION_URL"
