#!/bin/bash

# Create custom VPC network
gcloud compute networks create $NETWORK_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# Create subnet with Private Google Access enabled
gcloud compute networks subnets create $SUBNET_NAME \
    --network=$NETWORK_NAME \
    --region=$REGION \
    --range=$SUBNET_RANGE \
    --enable-private-ip-google-access

# Allocate IP range for private service connection (needed for Cloud SQL)
gcloud compute addresses create google-managed-services-$NETWORK_NAME \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --network=$NETWORK_NAME

# Create private VPC connection for Cloud SQL
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-$NETWORK_NAME \
    --network=$NETWORK_NAME

echo "VPC and subnet created successfully"
