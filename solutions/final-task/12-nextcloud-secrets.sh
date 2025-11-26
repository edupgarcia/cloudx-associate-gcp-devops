#!/usr/bin/env bash

# 12-nextcloud-secrets.sh
# Create Kubernetes secrets for Nextcloud admin and MySQL credentials

set -e

NAMESPACE="default"

echo "Creating nextcloud-admin secret..."
kubectl delete secret nextcloud-admin -n "${NAMESPACE}" >/dev/null 2>&1 || true
kubectl create secret generic nextcloud-admin -n "${NAMESPACE}" \
  --from-literal=NEXTCLOUD_ADMIN_USER="${NEXTCLOUD_ADMIN_USER}" \
  --from-literal=NEXTCLOUD_ADMIN_PASSWORD="${NEXTCLOUD_ADMIN_PASSWORD}"

echo "Creating nextcloud-mysql secret..."
kubectl delete secret nextcloud-mysql -n "${NAMESPACE}" >/dev/null 2>&1 || true
kubectl create secret generic nextcloud-mysql -n "${NAMESPACE}" \
  --from-literal=MYSQL_DATABASE="${APP_DB_NAME}" \
  --from-literal=MYSQL_USER="nextcloud" \
  --from-literal=MYSQL_PASSWORD="${APP_DB_PASSWORD}" \
  --from-literal=MYSQL_HOST="${NEXTCLOUD_DB_HOST}"

echo "Kubernetes secrets nextcloud-admin and nextcloud-mysql created in namespace ${NAMESPACE}."
