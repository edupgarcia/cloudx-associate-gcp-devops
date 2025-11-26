#!/usr/bin/env bash

# 09-bucket.sh
# Create Cloud Storage bucket for Nextcloud external data

set -e

BUCKET="${NEXTCLOUD_BUCKET}"

echo "Creating bucket gs://${BUCKET} in ${NEXTCLOUD_BUCKET_LOCATION} with fine-grained access..."
gcloud storage buckets create "gs://${BUCKET}" \
  --project="${PROJECT_ID}" \
  --location="${NEXTCLOUD_BUCKET_LOCATION}" \
  --uniform-bucket-level-access="${NEXTCLOUD_BUCKET_UNIFORM_ACCESS}"

echo "Bucket configuration complete."
