#!/bin/bash

# Create Cloud Storage bucket
gcloud storage buckets create gs://$BUCKET_NAME \
    --location=$REGION \
    --uniform-bucket-level-access

# Upload static files
gcloud storage cp ../../tasks/dynamic-serverless-website/index.html gs://$BUCKET_NAME/
gcloud storage cp ../../tasks/dynamic-serverless-website/404.html gs://$BUCKET_NAME/

# Make objects publicly readable (will be controlled by load balancer)
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME \
    --member=allUsers \
    --role=roles/storage.objectViewer

# Set main page and not found page
gcloud storage buckets update gs://$BUCKET_NAME \
    --web-main-page-suffix=index.html \
    --web-error-page=404.html

echo "Storage bucket created and static files uploaded"
