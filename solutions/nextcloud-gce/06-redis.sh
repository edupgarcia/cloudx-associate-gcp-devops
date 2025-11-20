#!/bin/bash
set -e

echo "Creating Memorystore Redis instance (this takes ~5 minutes)..."
gcloud redis instances create $REDIS_INSTANCE_NAME \
    --region=$REGION \
    --network=projects/$PROJECT_ID/global/networks/$NETWORK_NAME \
    --tier=standard \
    --size=1 \
    --redis-version=redis_6_x \
    --auth-enabled

echo "Setting Redis AUTH password..."
gcloud redis instances update $REDIS_INSTANCE_NAME \
    --region=$REGION \
    --update-auth-string="$REDIS_AUTH"

echo "Memorystore Redis instance created successfully."
