#!/usr/bin/env bash

# 13-nextcloud-helm.sh
# Deploy Nextcloud Helm chart configured for GCS, Redis, and Cloud SQL

set -e

NAMESPACE="default"
RELEASE_NAME="nextcloud"
VALUES_FILE="values.yaml"
REPO_DIR="cloudx-l2-final-task"

echo "Adding Nextcloud Helm repo..."
helm repo add nextcloud https://nextcloud.github.io/helm/ || true
helm repo update

echo "Ensuring reference repository is available..."
git clone https://github.com/tataranovich/cloudx-l2-final-task.git "${REPO_DIR}" 2>/dev/null || true

if [[ ! -f "${VALUES_FILE}" ]]; then
  echo "Creating ${VALUES_FILE} from values.example.yaml..."
  cp "${REPO_DIR}/values.example.yaml" "${VALUES_FILE}"
fi

echo "Creating secret nextcloud-gcs..."
kubectl delete secret nextcloud-gcs -n "${NAMESPACE}" >/dev/null 2>&1 || true
kubectl create secret generic nextcloud-gcs -n "${NAMESPACE}" \
  --from-literal=BUCKET_NAME="${NEXTCLOUD_BUCKET}" \
  --from-literal=ACCESS_KEY="${NEXTCLOUD_HMAC_ACCESS_KEY}" \
  --from-literal=SECRET_KEY="${NEXTCLOUD_HMAC_SECRET}"

echo "Deploying Nextcloud Helm release..."
helm upgrade --install "${RELEASE_NAME}" nextcloud/nextcloud -n "${NAMESPACE}" -f "${VALUES_FILE}" \
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

echo "Nextcloud Helm deployment initiated. It may take a few minutes for pods and ingress to become ready."

echo "Once the ingress IP is available, add it to /etc/hosts, e.g.:"
echo "  <INGRESS_IP> ${NEXTCLOUD_HOSTNAME}"
