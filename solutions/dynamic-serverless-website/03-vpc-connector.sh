#!/bin/bash

# Create VPC Access Connector for Cloud Functions to access Cloud SQL via private IP
gcloud compute networks vpc-access connectors create $CONNECTOR_NAME \
    --region=$REGION \
    --network=$NETWORK_NAME \
    --range=10.8.0.0/28

echo "VPC Connector created successfully"
