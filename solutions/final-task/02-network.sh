#!/usr/bin/env bash

# 02-network.sh
# Create VPC, subnet with secondary ranges for GKE, and private services range

set -e

echo "Creating VPC network ${NETWORK_NAME}..."
gcloud compute networks create "${NETWORK_NAME}" \
  --project "${PROJECT_ID}" \
  --subnet-mode=custom

echo "Creating subnet ${SUBNET_NAME} with secondary ranges..."
gcloud compute networks subnets create "${SUBNET_NAME}" \
  --project "${PROJECT_ID}" \
  --network "${NETWORK_NAME}" \
  --region "${SUBNET_REGION}" \
  --range "${SUBNET_PRIMARY_RANGE}" \
  --secondary-range "${PODS_RANGE_NAME}=${PODS_RANGE_CIDR}","${SERVICES_RANGE_NAME}=${SERVICES_RANGE_CIDR}" \
  --enable-private-ip-google-access

echo "Allocating IP range ${PRIVATE_SERVICE_CONNECT_RANGE_NAME} for private services..."
RANGE_BASE="${PRIVATE_SERVICE_CONNECT_RANGE_CIDR%/*}"
RANGE_PREFIX="${PRIVATE_SERVICE_CONNECT_RANGE_CIDR#*/}"

gcloud compute addresses create "${PRIVATE_SERVICE_CONNECT_RANGE_NAME}" \
  --project "${PROJECT_ID}" \
  --global \
  --purpose=VPC_PEERING \
  --addresses="${RANGE_BASE}" \
  --prefix-length="${RANGE_PREFIX}" \
  --network "${NETWORK_NAME}"

echo "Network and IP ranges configured."
