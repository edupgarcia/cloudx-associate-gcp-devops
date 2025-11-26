#!/usr/bin/env bash

# 03-nat.sh
# Create Cloud Router and Cloud NAT for internet access from private resources

set -e

echo "Creating Cloud Router ${CLOUD_ROUTER_NAME}..."
gcloud compute routers create "${CLOUD_ROUTER_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${NAT_REGION}" \
  --network "${NETWORK_NAME}"

echo "Creating Cloud NAT ${NAT_NAME}..."
gcloud compute routers nats create "${NAT_NAME}" \
  --project "${PROJECT_ID}" \
  --router "${CLOUD_ROUTER_NAME}" \
  --region "${NAT_REGION}" \
  --nat-all-subnet-ip-ranges \
  --auto-allocate-nat-external-ips

echo "Cloud NAT configuration complete."
