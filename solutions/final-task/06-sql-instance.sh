#!/usr/bin/env bash

# 06-sql-instance.sh
# Create HA Cloud SQL MySQL instance with private connectivity and backup settings

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh" >&2
  exit 1
fi

# Enable private services access (VPC peering) using the allocated range
if ! gcloud services vpc-peerings list \
  --network "${NETWORK_NAME}" \
  --project "${PROJECT_ID}" \
  --format="value(name)" | grep -q 'servicenetworking.googleapis.com'; then
  echo "Configuring private services access for Cloud SQL..."
  gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --network="${NETWORK_NAME}" \
    --ranges="${PRIVATE_SERVICE_CONNECT_RANGE_NAME}" \
    --project="${PROJECT_ID}"
else
  echo "Private services access already configured, skipping connect."
fi

# Create Cloud SQL instance
if ! gcloud sql instances describe "${SQL_INSTANCE_NAME}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  echo "Creating Cloud SQL instance ${SQL_INSTANCE_NAME}... (this may take ~10 minutes)"
  gcloud sql instances create "${SQL_INSTANCE_NAME}" \
    --project="${PROJECT_ID}" \
    --database-version="${SQL_DATABASE_VERSION}" \
    --tier="${SQL_TIER}" \
    --region="${SQL_REGION}" \
    --storage-type="${SQL_STORAGE_TYPE}" \
    --storage-size="${SQL_STORAGE_SIZE_GB}" \
    --storage-auto-increase="${SQL_AUTO_STORAGE_INCREASE}" \
    --availability-type=REGIONAL \
    --primary-zone="${SQL_PRIMARY_ZONE}" \
    --secondary-zone="${SQL_SECONDARY_ZONE}" \
    --backup-start-time=03:00 \
    --backup-location="${SQL_BACKUP_LOCATION}" \
    --enable-point-in-time-recovery \
    --maintenance-window-day="${SQL_MAINTENANCE_WINDOW_DAY}" \
    --maintenance-window-hour="${SQL_MAINTENANCE_WINDOW_HOUR}" \
    --maintenance-release-channel=production \
    --network="projects/${PROJECT_ID}/global/networks/${NETWORK_NAME}" \
    --no-assign-ip \
    --root-password="${SQL_ROOT_PASSWORD}"
else
  echo "Cloud SQL instance ${SQL_INSTANCE_NAME} already exists, skipping create."
fi

# Configure backup retention
echo "Updating backup configuration for ${SQL_INSTANCE_NAME}..."
gcloud sql instances patch "${SQL_INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --backup-start-time=03:00 \
  --backup-location="${SQL_BACKUP_LOCATION}" \
  --enable-point-in-time-recovery \
  --retained-backups="${SQL_BACKUP_RETENTION_DAYS}" \
  --quiet

echo "Cloud SQL instance configured."