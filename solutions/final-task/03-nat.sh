#!/usr/bin/env bash

# 03-nat.sh
# Create Cloud Router and Cloud NAT for internet access from private resources

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

# Create Cloud Router
if ! gcloud compute routers describe "${CLOUD_ROUTER_NAME}" \
  --project "${PROJECT_ID}" --region "${NAT_REGION}" >/dev/null 2>&1; then
  echo "Creating Cloud Router ${CLOUD_ROUTER_NAME}..."
  gcloud compute routers create "${CLOUD_ROUTER_NAME}" \
    --project "${PROJECT_ID}" \
    --region "${NAT_REGION}" \
    --network "${NETWORK_NAME}"
else
  echo "Cloud Router ${CLOUD_ROUTER_NAME} already exists, skipping create."
fi

# Create Cloud NAT
if ! gcloud compute routers nats describe "${NAT_NAME}" \
  --project "${PROJECT_ID}" \
  --router "${CLOUD_ROUTER_NAME}" \
  --region "${NAT_REGION}" >/dev/null 2>&1; then
  echo "Creating Cloud NAT ${NAT_NAME}..."
  gcloud compute routers nats create "${NAT_NAME}" \
    --project "${PROJECT_ID}" \
    --router "${CLOUD_ROUTER_NAME}" \
    --region "${NAT_REGION}" \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips
else
  echo "Cloud NAT ${NAT_NAME} already exists, skipping create."
fi

echo "Cloud NAT configuration complete."