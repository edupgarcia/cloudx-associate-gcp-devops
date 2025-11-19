#!/bin/bash

# Create custom VPC network
gcloud compute networks create $NETWORK_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# Create /24 subnet
gcloud compute networks subnets create private-subnet \
    --network=$NETWORK_NAME \
    --region=$REGION \
    --range=$SUBNET_RANGE \
    --enable-private-ip-google-access
