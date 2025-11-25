#!/usr/bin/env bash

# 02-network.sh
# Create VPC, subnet with secondary ranges for GKE, and private services range

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

# Create VPC network (custom mode)
if ! gcloud compute networks describe "${NETWORK_NAME}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  echo "Creating VPC network ${NETWORK_NAME}..."
  gcloud compute networks create "${NETWORK_NAME}" \
    --project "${PROJECT_ID}" \
    --subnet-mode=custom
else
  echo "VPC network ${NETWORK_NAME} already exists, skipping create."
fi

# Create subnet with secondary ranges for pods and services
if ! gcloud compute networks subnets describe "${SUBNET_NAME}" \
  --project "${PROJECT_ID}" --region "${SUBNET_REGION}" >/dev/null 2>&1; then
  echo "Creating subnet ${SUBNET_NAME} with secondary ranges..."
  gcloud compute networks subnets create "${SUBNET_NAME}" \
    --project "${PROJECT_ID}" \
    --network "${NETWORK_NAME}" \
    --region "${SUBNET_REGION}" \
    --range "${SUBNET_PRIMARY_RANGE}" \
    --secondary-range "${PODS_RANGE_NAME}=${PODS_RANGE_CIDR}","${SERVICES_RANGE_NAME}=${SERVICES_RANGE_CIDR}" \
    --enable-private-ip-google-access
else
  echo "Subnet ${SUBNET_NAME} already exists, skipping create."
fi

# Allocate IP range for private services connections (for Cloud SQL private IP)
if ! gcloud compute addresses describe "${PRIVATE_SERVICE_CONNECT_RANGE_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${REGION}" \
  --purpose=VPC_PEERING >/dev/null 2>&1; then
  echo "Allocating IP range ${PRIVATE_SERVICE_CONNECT_RANGE_NAME} for private services..."
  gcloud compute addresses create "${PRIVATE_SERVICE_CONNECT_RANGE_NAME}" \
    --project "${PROJECT_ID}" \
    --region "${REGION}" \
    --subnet-region "${REGION}" \
    --purpose=VPC_PEERING \
    --prefix-length=20 \
    --network "${NETWORK_NAME}" \
    --addresses "${PRIVATE_SERVICE_CONNECT_RANGE_CIDR}"
else
  echo "Private services range ${PRIVATE_SERVICE_CONNECT_RANGE_NAME} already exists, skipping create."
fi

echo "Network and IP ranges configured."