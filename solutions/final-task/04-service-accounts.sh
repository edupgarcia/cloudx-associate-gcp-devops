#!/usr/bin/env bash

# 04-service-accounts.sh
# Create GKE and Nextcloud service accounts and bind required IAM roles

set -e

echo "Creating GKE service account ${GKE_SA_NAME}..."
gcloud iam service-accounts create "${GKE_SA_NAME}" \
  --project "${PROJECT_ID}" \
  --display-name "${GKE_SA_NAME}"

GKE_SA_EMAIL="${GKE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Binding IAM roles to ${GKE_SA_EMAIL}..."
for ROLE in \
  roles/artifactregistry.reader \
  roles/logging.logWriter \
  roles/monitoring.metricWriter \
  roles/monitoring.viewer \
  roles/stackdriver.resourceMetadata.writer \
  roles/storage.objectViewer
do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "serviceAccount:${GKE_SA_EMAIL}" \
    --role "${ROLE}"
done

echo "Creating Nextcloud service account ${NEXTCLOUD_SA_NAME}..."
gcloud iam service-accounts create "${NEXTCLOUD_SA_NAME}" \
  --project "${PROJECT_ID}" \
  --display-name "${NEXTCLOUD_SA_NAME}"

NEXTCLOUD_SA_EMAIL="${NEXTCLOUD_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Binding IAM roles to ${NEXTCLOUD_SA_EMAIL}..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${NEXTCLOUD_SA_EMAIL}" \
  --role "roles/storage.objectAdmin"

export GKE_SA_EMAIL
export NEXTCLOUD_SA_EMAIL

echo "Service accounts and IAM bindings configured."
