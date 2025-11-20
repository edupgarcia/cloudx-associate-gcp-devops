#!/bin/bash
set -e

echo "Creating VPC connector for Cloud Scheduler..."
gcloud compute networks vpc-access connectors create $VPC_CONNECTOR_NAME \
    --region=$REGION \
    --network=$NETWORK_NAME \
    --range=$VPC_CONNECTOR_CIDR \
    --min-instances=2 \
    --max-instances=3 \
    --machine-type=e2-micro

echo "VPC connector created successfully."
