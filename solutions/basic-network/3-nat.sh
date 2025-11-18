#!/bin/bash

# Create Cloud Router (required for Cloud NAT)
gcloud compute routers create nat-router \
    --network=$NETWORK_NAME \
    --region=$REGION

# Create Cloud NAT configuration
gcloud compute routers nats create nat-config \
    --router=nat-router \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

