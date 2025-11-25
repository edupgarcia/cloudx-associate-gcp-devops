#!/usr/bin/env bash

# 08-redis.sh
# Create Memorystore Redis instance

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

if ! gcloud redis instances describe "${REDIS_INSTANCE_NAME}" \
  --project "${PROJECT_ID}" --region "${REDIS_REGION}" >/dev/null 2>&1; then
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
else
  echo "Memorystore Redis instance ${REDIS_INSTANCE_NAME} already exists, skipping create."
fi

echo "Redis configuration complete."