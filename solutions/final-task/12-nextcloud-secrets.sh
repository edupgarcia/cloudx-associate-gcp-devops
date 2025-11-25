#!/usr/bin/env bash

# 12-nextcloud-secrets.sh
# Create Kubernetes secrets for Nextcloud admin and MySQL credentials

set -euo pipefail

if [[ -z "${APP_DB_PASSWORD:-}" || -z "${SQL_ROOT_PASSWORD:-}" ]]; then
  echo "ERROR: Database passwords not set. Run: source 01-setup.sh" >&2
  exit 1
fi

if [[ -z "${NEXTCLOUD_ADMIN_USER:-}" || -z "${NEXTCLOUD_ADMIN_PASSWORD:-}" ]]; then
  echo "ERROR: Nextcloud admin credentials not set. Run: source 01-setup.sh" >&2
  exit 1
fi

NAMESPACE="default"

# nextcloud-admin secret
kubectl delete secret nextcloud-admin -n "${NAMESPACE}" >/dev/null 2>&1 || true
kubectl create secret generic nextcloud-admin -n "${NAMESPACE}" \
  --from-literal=NEXTCLOUD_ADMIN_USER="${NEXTCLOUD_ADMIN_USER}" \
  --from-literal=NEXTCLOUD_ADMIN_PASSWORD="${NEXTCLOUD_ADMIN_PASSWORD}"

# nextcloud-mysql secret
kubectl delete secret nextcloud-mysql -n "${NAMESPACE}" >/dev/null 2>&1 || true
kubectl create secret generic nextcloud-mysql -n "${NAMESPACE}" \
  --from-literal=MYSQL_DATABASE="${APP_DB_NAME}" \
  --from-literal=MYSQL_USER="nextcloud" \
  --from-literal=MYSQL_PASSWORD="${APP_DB_PASSWORD}" \
  --from-literal=MYSQL_HOST="${NEXTCLOUD_DB_HOST}"

echo "Kubernetes secrets nextcloud-admin and nextcloud-mysql created in namespace ${NAMESPACE}."