#!/bin/bash
set -e

echo "Creating VPC network..."
gcloud compute networks create $NETWORK_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

echo "Creating subnet..."
gcloud compute networks subnets create $SUBNET_NAME \
    --network=$NETWORK_NAME \
    --region=$REGION \
    --range=$SUBNET_CIDR \
    --enable-private-ip-google-access

echo "VPC network and subnet created successfully."
