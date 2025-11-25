#!/usr/bin/env bash

# 04-service-accounts.sh
# Create GKE and Nextcloud service accounts and bind required IAM roles

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

create_sa() {
  local sa_name=$1
  local sa_email=${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com

  if ! gcloud iam service-accounts describe "${sa_email}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
    echo "Creating service account ${sa_email}..."
    gcloud iam service-accounts create "${sa_name}" \
      --project "${PROJECT_ID}" \
      --display-name "${sa_name}"
  else
    echo "Service account ${sa_email} already exists, skipping create."
  fi
}

bind_project_role() {
  local sa_email=$1
  local role=$2
  echo "Binding role ${role} to ${sa_email}..."
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "serviceAccount:${sa_email}" \
    --role "${role}" \
    --quiet >/dev/null
}

# GKE service account (kubernetes)
create_sa "${GKE_SA_NAME}"
GKE_SA_EMAIL="${GKE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Required roles for GKE SA
bind_project_role "${GKE_SA_EMAIL}" "roles/artifactregistry.reader"
bind_project_role "${GKE_SA_EMAIL}" "roles/logging.logWriter"
bind_project_role "${GKE_SA_EMAIL}" "roles/monitoring.metricWriter"
bind_project_role "${GKE_SA_EMAIL}" "roles/monitoring.viewer"
bind_project_role "${GKE_SA_EMAIL}" "roles/stackdriver.resourceMetadata.writer"
bind_project_role "${GKE_SA_EMAIL}" "roles/storage.objectViewer"

# Nextcloud service account (nextcloud)
create_sa "${NEXTCLOUD_SA_NAME}"
NEXTCLOUD_SA_EMAIL="${NEXTCLOUD_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Required roles for Nextcloud SA
bind_project_role "${NEXTCLOUD_SA_EMAIL}" "roles/storage.objectAdmin"

# Export resolved emails
export GKE_SA_EMAIL
export NEXTCLOUD_SA_EMAIL

echo "Service accounts and IAM bindings configured."