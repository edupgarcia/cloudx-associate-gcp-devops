#!/usr/bin/env bash

# 07-sql-db-user.sh
# Create Nextcloud database and user in Cloud SQL

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

if [[ -z "${SQL_ROOT_PASSWORD:-}" ]]; then
  echo "ERROR: SQL_ROOT_PASSWORD is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

# Create database if not exists
SQL_INSTANCE_CONNECTION_NAME="${PROJECT_ID}:${SQL_REGION}:${SQL_INSTANCE_NAME}"

echo "Creating database ${APP_DB_NAME} if it does not exist..."
gcloud sql databases create "${APP_DB_NAME}" \
  --instance="${SQL_INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --charset="${APP_DB_CHARSET}" \
  --collation="${APP_DB_COLLATION}" \
  || echo "Database ${APP_DB_NAME} may already exist, continuing."

# Create user with password, allowed from any host ('%')
echo "Creating user nextcloud for database ${APP_DB_NAME}..."
gcloud sql users create "nextcloud" \
  --instance="${SQL_INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --password="${APP_DB_PASSWORD}" \
  --host="%" \
  || echo "User nextcloud may already exist, updating password..."

# Ensure password is set
if gcloud sql users list --instance="${SQL_INSTANCE_NAME}" --project="${PROJECT_ID}" --format="value(name)" | grep -q '^nextcloud$'; then
  gcloud sql users set-password "nextcloud" \
    --instance="${SQL_INSTANCE_NAME}" \
    --project="${PROJECT_ID}" \
    --password="${APP_DB_PASSWORD}"
fi

echo "Database and user configuration complete."