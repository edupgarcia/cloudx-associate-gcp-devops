#!/usr/bin/env bash

# 10-build-image.sh
# Build Nextcloud Docker image from reference repo and push to Container/Artifact Registry

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

REPO_DIR="cloudx-l2-final-task"
IMAGE_REPO="${NEXTCLOUD_IMAGE_REPOSITORY}"
IMAGE_TAG="${NEXTCLOUD_IMAGE_TAG}"
FULL_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

# Clone repo if not present
if [[ ! -d "${REPO_DIR}" ]]; then
  echo "Cloning reference repository..."
  git clone https://github.com/tataranovich/cloudx-l2-final-task.git
fi

cd "${REPO_DIR}/nextcloud-docker"

# Configure gcloud auth for Docker
 echo "Configuring gcloud auth for Docker..."
 gcloud auth configure-docker --quiet

# Build image
 echo "Building Docker image ${FULL_IMAGE}..."
 docker build -t "${FULL_IMAGE}" .

# Push image
 echo "Pushing image ${FULL_IMAGE}..."
 docker push "${FULL_IMAGE}"

echo "Image build and push complete: ${FULL_IMAGE}"