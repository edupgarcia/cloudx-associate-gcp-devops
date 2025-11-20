#!/bin/bash

# Create storage buckets for ingest, unpack, and transform stages

echo "Creating storage buckets..."

# Create ingest bucket
gcloud storage buckets create gs://$INGEST_BUCKET \
    --location=$REGION \
    --uniform-bucket-level-access

echo "✓ Created ingest bucket: gs://$INGEST_BUCKET"

# Create unpack bucket
gcloud storage buckets create gs://$UNPACK_BUCKET \
    --location=$REGION \
    --uniform-bucket-level-access

echo "✓ Created unpack bucket: gs://$UNPACK_BUCKET"

# Create transform bucket
gcloud storage buckets create gs://$TRANSFORM_BUCKET \
    --location=$REGION \
    --uniform-bucket-level-access

echo "✓ Created transform bucket: gs://$TRANSFORM_BUCKET"

echo ""
echo "All storage buckets created successfully."
