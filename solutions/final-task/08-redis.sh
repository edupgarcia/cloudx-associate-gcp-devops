#!/usr/bin/env bash

# 08-redis.sh
# Create Memorystore Redis instance

set -e

echo "Creating Memorystore Redis instance ${REDIS_INSTANCE_NAME}... (this may take several minutes)"
gcloud redis instances create "${REDIS_INSTANCE_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${REDIS_REGION}" \
  --tier "${REDIS_TIER}" \
  --memory-size="${REDIS_MEMORY_SIZE_GB}" \
  --redis-version="${REDIS_VERSION}" \
  --transit-encryption-mode=DISABLED \
  --connect-mode=PRIVATE_SERVICE_ACCESS \
  --network="projects/${PROJECT_ID}/global/networks/${NETWORK_NAME}"

echo "Redis configuration complete."
