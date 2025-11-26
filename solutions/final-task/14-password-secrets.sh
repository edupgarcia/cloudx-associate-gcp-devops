#!/usr/bin/env bash

# 14-password-secrets.sh
# Store generated passwords in Secret Manager ("password manager")
# Prerequisite: source 01-setup.sh so PROJECT_ID and passwords are in the environment.

set -e

PROJECT="${PROJECT_ID}"

# Temporary files for secrets
ROOT_FILE="/tmp/gcp-devops-sql-root-password.txt"
APP_FILE="/tmp/gcp-devops-app-db-password.txt"
ADMIN_FILE="/tmp/gcp-devops-nextcloud-admin-password.txt"

printf '%s' "${SQL_ROOT_PASSWORD}" > "${ROOT_FILE}"
printf '%s' "${APP_DB_PASSWORD}" > "${APP_FILE}"
printf '%s' "${NEXTCLOUD_ADMIN_PASSWORD}" > "${ADMIN_FILE}"

echo "Creating Secret Manager secrets for database and Nextcloud passwords..."

gcloud secrets create gcp-devops-sql-root-password \
  --project="${PROJECT}" \
  --replication-policy="automatic" \
  --data-file="${ROOT_FILE}"

gcloud secrets create gcp-devops-app-db-password \
  --project="${PROJECT}" \
  --replication-policy="automatic" \
  --data-file="${APP_FILE}"

gcloud secrets create gcp-devops-nextcloud-admin-password \
  --project="${PROJECT}" \
  --replication-policy="automatic" \
  --data-file="${ADMIN_FILE}"

rm -f "${ROOT_FILE}" "${APP_FILE}" "${ADMIN_FILE}"

echo "Secrets created:"
echo "  gcp-devops-sql-root-password"
echo "  gcp-devops-app-db-password"
echo "  gcp-devops-nextcloud-admin-password"
