#!/usr/bin/env bash

# 07-sql-db-user.sh
# Create Nextcloud database and user in Cloud SQL

set -e

echo "Creating database ${APP_DB_NAME}..."
gcloud sql databases create "${APP_DB_NAME}" \
  --instance="${SQL_INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --charset="${APP_DB_CHARSET}" \
  --collation="${APP_DB_COLLATION}"

echo "Creating user nextcloud for database ${APP_DB_NAME}..."
gcloud sql users create "nextcloud" \
  --instance="${SQL_INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --password="${APP_DB_PASSWORD}" \
  --host="%"

echo "Database and user configuration complete."
