#!/usr/bin/env bash

# 13-nextcloud-helm.sh
# Deploy Nextcloud Helm chart configured for GCS, Redis, and Cloud SQL

set -euo pipefail

if [[ -z "${NEXTCLOUD_HMAC_ACCESS_KEY:-}" || -z "${NEXTCLOUD_HMAC_SECRET:-}" ]]; then
  echo "ERROR: NEXTCLOUD_HMAC_ACCESS_KEY / NEXTCLOUD_HMAC_SECRET not set." >&2
  echo "Create the HMAC key for the nextcloud service account and update .env, then source .env." >&2
  exit 1
fi

if [[ -z "${NEXTCLOUD_BUCKET:-}" ]]; then
  echo "ERROR: NEXTCLOUD_BUCKET not set. Run: source 01-setup.sh" >&2
  exit 1
fi

NAMESPACE="default"
RELEASE_NAME="nextcloud"
VALUES_FILE="values.yaml"

# Ensure nextcloud Helm repo is added
helm repo add nextcloud https://nextcloud.github.io/helm/ || true
helm repo update

# Prepare values.yaml from example if not present
REPO_DIR="cloudx-l2-final-task"
if [[ ! -f "${VALUES_FILE}" ]]; then
  if [[ ! -d "${REPO_DIR}" ]]; then
    echo "Cloning reference repository to copy values.example.yaml..."
    git clone https://github.com/tataranovich/cloudx-l2-final-task.git
  fi
  cp "${REPO_DIR}/values.example.yaml" "${VALUES_FILE}"
  echo "Created ${VALUES_FILE} from values.example.yaml. Please review it if needed."
fi

# Create/refresh secret with HMAC + bucket info for GCS interoperability
kubectl delete secret nextcloud-gcs -n "${NAMESPACE}" >/dev/null 2>&1 || true
kubectl create secret generic nextcloud-gcs -n "${NAMESPACE}" \
  --from-literal=BUCKET_NAME="${NEXTCLOUD_BUCKET}" \
  --from-literal=ACCESS_KEY="${NEXTCLOUD_HMAC_ACCESS_KEY}" \
  --from-literal=SECRET_KEY="${NEXTCLOUD_HMAC_SECRET}"

# Install or upgrade Nextcloud Helm chart
if helm status "${RELEASE_NAME}" -n "${NAMESPACE}" >/dev/null 2>&1; then
  echo "Upgrading existing Nextcloud release..."
  helm upgrade "${RELEASE_NAME}" nextcloud/nextcloud -n "${NAMESPACE}" -f "${VALUES_FILE}" \
    --set image.repository="${NEXTCLOUD_IMAGE_REPOSITORY}" \
    --set image.tag="${NEXTCLOUD_IMAGE_TAG}" \
    --set ingress.enabled=true \
    --set ingress.hosts[0].host="${NEXTCLOUD_HOSTNAME}" \
    --set redis.enabled=true \
    --set redis.host="${NEXTCLOUD_REDIS_HOST}" \
    --set externalDatabase.enabled=true \
    --set externalDatabase.type=mysql \
    --set externalDatabase.host="${NEXTCLOUD_DB_HOST}" \
    --set externalDatabase.database="${APP_DB_NAME}" \
    --set externalDatabase.user="nextcloud" \
    --set externalDatabase.existingSecret=nextcloud-mysql \
    --set externalDatabase.secretKeys.password=MYSQL_PASSWORD
else
  echo "Installing Nextcloud release..."
  helm install "${RELEASE_NAME}" nextcloud/nextcloud -n "${NAMESPACE}" -f "${VALUES_FILE}" \
    --set image.repository="${NEXTCLOUD_IMAGE_REPOSITORY}" \
    --set image.tag="${NEXTCLOUD_IMAGE_TAG}" \
    --set ingress.enabled=true \
    --set ingress.hosts[0].host="${NEXTCLOUD_HOSTNAME}" \
    --set redis.enabled=true \
    --set redis.host="${NEXTCLOUD_REDIS_HOST}" \
    --set externalDatabase.enabled=true \
    --set externalDatabase.type=mysql \
    --set externalDatabase.host="${NEXTCLOUD_DB_HOST}" \
    --set externalDatabase.database="${APP_DB_NAME}" \
    --set externalDatabase.user="nextcloud" \
    --set externalDatabase.existingSecret=nextcloud-mysql \
    --set externalDatabase.secretKeys.password=MYSQL_PASSWORD
fi

echo "Nextcloud Helm deployment initiated. It may take a few minutes for pods and ingress to become ready."

echo "Once the ingress IP is available, add it to /etc/hosts, e.g.:"
echo "  <INGRESS_IP> ${NEXTCLOUD_HOSTNAME}"