#!/usr/bin/env bash

# 10-build-image.sh
# Build Nextcloud Docker image from reference repo and push to Container/Artifact Registry

set -e

REPO_DIR="cloudx-l2-final-task"
IMAGE_REPO="${NEXTCLOUD_IMAGE_REPOSITORY}"
IMAGE_TAG="${NEXTCLOUD_IMAGE_TAG}"
FULL_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

echo "Cloning reference repository (if needed)..."
git clone https://github.com/tataranovich/cloudx-l2-final-task.git "${REPO_DIR}" 2>/dev/null || true

cd "${REPO_DIR}/nextcloud-docker"

echo "Configuring gcloud auth for Docker..."
gcloud auth configure-docker --quiet

echo "Building Docker image ${FULL_IMAGE}..."
docker build -t "${FULL_IMAGE}" .

echo "Pushing image ${FULL_IMAGE}..."
docker push "${FULL_IMAGE}"

echo "Image build and push complete: ${FULL_IMAGE}"
