#!/usr/bin/env bash

# 09-bucket.sh
# Create Cloud Storage bucket for Nextcloud external data

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

BUCKET="${NEXTCLOUD_BUCKET}"

if ! gcloud storage buckets describe "gs://${BUCKET}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  echo "Creating bucket gs://${BUCKET} in ${NEXTCLOUD_BUCKET_LOCATION} with fine-grained access..."
  gcloud storage buckets create "gs://${BUCKET}" \
    --project="${PROJECT_ID}" \
    --location="${NEXTCLOUD_BUCKET_LOCATION}" \
    --uniform-bucket-level-access="${NEXTCLOUD_BUCKET_UNIFORM_ACCESS}"
else
  echo "Bucket gs://${BUCKET} already exists, skipping create."
fi

echo "Bucket configuration complete."