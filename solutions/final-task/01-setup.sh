#!/usr/bin/env bash

# Final task setup script
# Usage: source 01-setup.sh

set -u

# -----------------------------------------------------------------------------
# Project and region configuration
# -----------------------------------------------------------------------------

# GOOGLE_CLOUD_PROJECT is set automatically in Cloud Shell. Fall back to gcloud
if [[ -z "${GOOGLE_CLOUD_PROJECT:-}" ]]; then
  PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"
else
  PROJECT_ID="$GOOGLE_CLOUD_PROJECT"
fi

if [[ -z "${PROJECT_ID}" ]]; then
  echo "ERROR: PROJECT_ID is not set and could not be inferred from gcloud config."
  echo "Set GOOGLE_CLOUD_PROJECT or run: gcloud config set project <PROJECT_ID>"
  return 1 2>/dev/null || exit 1
fi

export PROJECT_ID
export GOOGLE_CLOUD_PROJECT="$PROJECT_ID"

export REGION="us-central1"
export ZONE_A="us-central1-a"
export ZONE_B="us-central1-b"
# Default zone for zonal commands
export ZONE="$ZONE_A"

# Your client IP for GKE control plane access
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"

# -----------------------------------------------------------------------------
# VPC & subnet configuration (Task 1)
# -----------------------------------------------------------------------------

export NETWORK_NAME="network"
export SUBNET_NAME="us-central1-subnet"
export SUBNET_REGION="$REGION"
export SUBNET_PRIMARY_RANGE="10.1.0.0/24"

# GKE secondary IP ranges
export PODS_RANGE_NAME="pods"
export PODS_RANGE_CIDR="10.2.0.0/20"

export SERVICES_RANGE_NAME="services"
export SERVICES_RANGE_CIDR="10.3.0.0/20"

# Enable Private Google Access on subnet
export ENABLE_PRIVATE_GOOGLE_ACCESS="true"

# -----------------------------------------------------------------------------
# Private Service Connect range (Task 2)
# -----------------------------------------------------------------------------

export PRIVATE_SERVICE_CONNECT_RANGE_NAME="private-services"
export PRIVATE_SERVICE_CONNECT_RANGE_CIDR="10.4.0.0/20"

# -----------------------------------------------------------------------------
# Cloud NAT (Task 3)
# -----------------------------------------------------------------------------

export NAT_NAME="nat-gateway"
export NAT_REGION="$REGION"
export CLOUD_ROUTER_NAME="nat-router"

# NAT should cover primary + secondary ranges for all subnets
export NAT_SOURCE_SUBNETWORK_IP_RANGES="ALL_SUBNETWORKS_ALL_IP_RANGES"

# -----------------------------------------------------------------------------
# Service accounts (Tasks 4 & 5)
# -----------------------------------------------------------------------------

export GKE_SA_NAME="kubernetes"
export GKE_SA_EMAIL="${GKE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

export NEXTCLOUD_SA_NAME="nextcloud"
export NEXTCLOUD_SA_EMAIL="${NEXTCLOUD_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# -----------------------------------------------------------------------------
# GKE cluster (Task 6)
# -----------------------------------------------------------------------------

export GKE_CLUSTER_NAME="cluster"
export GKE_CLUSTER_LOCATION="$REGION"      # regional cluster
export GKE_CLUSTER_ZONES="${ZONE_A},${ZONE_B}"
export GKE_NODE_COUNT="2"
export GKE_MACHINE_TYPE="n1-standard-1"

# Control plane CIDR
export GKE_MASTER_IPV4_CIDR="172.16.0.0/28"

# Use existing secondary ranges
export GKE_PODS_RANGE_NAME="$PODS_RANGE_NAME"
export GKE_SERVICES_RANGE_NAME="$SERVICES_RANGE_NAME"

# -----------------------------------------------------------------------------
# Cloud SQL MySQL (Tasks 7 & 8)
# -----------------------------------------------------------------------------

export SQL_INSTANCE_NAME="database"
export SQL_DATABASE_VERSION="MYSQL_8_0"
export SQL_REGION="$REGION"
export SQL_PRIMARY_ZONE="$ZONE_A"
export SQL_SECONDARY_ZONE="$ZONE_B"

# Machine & storage
export SQL_TIER="db-custom-1-3840"    # 1 vCPU, 3.75 GB
export SQL_STORAGE_TYPE="SSD"
export SQL_STORAGE_SIZE_GB="10"
export SQL_AUTO_STORAGE_INCREASE="true"

# Backups & maintenance
export SQL_BACKUP_LOCATION="us"
export SQL_BACKUP_ENABLED="true"
export SQL_BACKUP_RETENTION_DAYS="30"
export SQL_PITR_ENABLED="true"        # 7 days as per task
export SQL_MAINTENANCE_WINDOW_DAY="SUN"
export SQL_MAINTENANCE_WINDOW_HOUR="0"  # 00:00–01:00

# Private IP
export SQL_USE_PRIVATE_IP="true"

# Application DB
export APP_DB_NAME="nextcloud"
export APP_DB_CHARSET="utf8mb4"
export APP_DB_COLLATION="utf8mb4_general_ci"

# Generate strong passwords
export SQL_ROOT_PASSWORD="$(openssl rand -base64 18)"
export APP_DB_PASSWORD="$(openssl rand -base64 18)"

# -----------------------------------------------------------------------------
# Memorystore Redis (Task 9)
# -----------------------------------------------------------------------------

export REDIS_INSTANCE_NAME="redis"
export REDIS_REGION="$REGION"
export REDIS_TIER="STANDARD_HA"
export REDIS_MEMORY_SIZE_GB="1"
export REDIS_VERSION="REDIS_5_0"

# -----------------------------------------------------------------------------
# Cloud Storage bucket (Task 10)
# -----------------------------------------------------------------------------

export NEXTCLOUD_BUCKET="${PROJECT_ID}-nextcloud-external-data"
export NEXTCLOUD_BUCKET_LOCATION="$REGION"
# false => fine-grained access
export NEXTCLOUD_BUCKET_UNIFORM_ACCESS="false"

# -----------------------------------------------------------------------------
# HMAC for Nextcloud SA (Task 11)
# -----------------------------------------------------------------------------

# These must be pasted after creation in the console
export NEXTCLOUD_HMAC_ACCESS_KEY=""
export NEXTCLOUD_HMAC_SECRET=""

# -----------------------------------------------------------------------------
# Nextcloud / Helm configuration (Tasks 12–15)
# -----------------------------------------------------------------------------

export NEXTCLOUD_IMAGE_REPOSITORY="gcr.io/${PROJECT_ID}/nextcloud"
export NEXTCLOUD_IMAGE_TAG="latest"

export NEXTCLOUD_REDIS_HOST="${REDIS_INSTANCE_NAME}"
export NEXTCLOUD_DB_HOST="${SQL_INSTANCE_NAME}"

export NEXTCLOUD_ADMIN_USER="admin"
export NEXTCLOUD_ADMIN_PASSWORD="admin123"

export NEXTCLOUD_HOSTNAME="nextcloud.kube.home"

# -----------------------------------------------------------------------------
# gcloud configuration and API enablement
# -----------------------------------------------------------------------------

gcloud config set project "$PROJECT_ID" >/dev/null

echo ""
echo "Enabling required APIs..."

echo "Enabling Compute Engine API..."
gcloud services enable compute.googleapis.com

echo "Enabling Kubernetes Engine API..."
gcloud services enable container.googleapis.com

echo "Enabling Cloud SQL Admin API..."
gcloud services enable sqladmin.googleapis.com

echo "Enabling Memorystore Redis API..."
gcloud services enable redis.googleapis.com

echo "Enabling Cloud Storage API..."
gcloud services enable storage.googleapis.com

echo "Enabling Service Networking API..."
gcloud services enable servicenetworking.googleapis.com

echo "Enabling Cloud Monitoring API..."
gcloud services enable monitoring.googleapis.com

echo "Enabling Cloud Logging API..."
gcloud services enable logging.googleapis.com

echo "Enabling Artifact Registry API..."
gcloud services enable artifactregistry.googleapis.com

echo "Enabling Cloud Resource Manager API..."
gcloud services enable cloudresourcemanager.googleapis.com

echo ""
echo "All APIs enabled successfully."
echo ""

# -----------------------------------------------------------------------------
# Display configuration summary
# -----------------------------------------------------------------------------

echo "Configuration:"
echo "PROJECT_ID: ${PROJECT_ID}"
echo "REGION: ${REGION}"
echo "ZONES: ${ZONE_A}, ${ZONE_B}"
echo "EXTERNAL_IP: ${EXTERNAL_IP}"
echo ""

echo "Network:"
echo "  NETWORK_NAME: ${NETWORK_NAME}"
echo "  SUBNET_NAME: ${SUBNET_NAME}"
echo "  SUBNET_PRIMARY_RANGE: ${SUBNET_PRIMARY_RANGE}"
echo "  PODS_RANGE: ${PODS_RANGE_NAME} (${PODS_RANGE_CIDR})"
echo "  SERVICES_RANGE: ${SERVICES_RANGE_NAME} (${SERVICES_RANGE_CIDR})"
echo "  PRIVATE_SERVICE_CONNECT_RANGE: ${PRIVATE_SERVICE_CONNECT_RANGE_NAME} (${PRIVATE_SERVICE_CONNECT_RANGE_CIDR})"
echo ""

echo "GKE:"
echo "  GKE_CLUSTER_NAME: ${GKE_CLUSTER_NAME}"
echo "  GKE_CLUSTER_LOCATION: ${GKE_CLUSTER_LOCATION}"
echo "  GKE_CLUSTER_ZONES: ${GKE_CLUSTER_ZONES}"
echo "  GKE_NODE_COUNT: ${GKE_NODE_COUNT}"
echo "  GKE_MACHINE_TYPE: ${GKE_MACHINE_TYPE}"
echo ""

echo "Cloud SQL:"
echo "  SQL_INSTANCE_NAME: ${SQL_INSTANCE_NAME}"
echo "  APP_DB_NAME: ${APP_DB_NAME}"
echo "  APP_DB_USER: nextcloud"
echo ""

echo "Redis:"
echo "  REDIS_INSTANCE_NAME: ${REDIS_INSTANCE_NAME}"
echo ""

echo "Storage:"
echo "  NEXTCLOUD_BUCKET: ${NEXTCLOUD_BUCKET}"
echo ""

echo "Nextcloud Helm:"
echo "  NEXTCLOUD_IMAGE_REPOSITORY: ${NEXTCLOUD_IMAGE_REPOSITORY}"
echo "  NEXTCLOUD_IMAGE_TAG: ${NEXTCLOUD_IMAGE_TAG}"
echo "  NEXTCLOUD_HOSTNAME: ${NEXTCLOUD_HOSTNAME}"
echo ""

echo "Setup complete."
echo ""

# -----------------------------------------------------------------------------
# Persist configuration to .env
# -----------------------------------------------------------------------------

echo "Saving environment variables to .env file..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat > "${SCRIPT_DIR}/.env" <<ENV_EOF
# Final task configuration
# Generated: $(date)

# Core project settings
PROJECT_ID="${PROJECT_ID}"
GOOGLE_CLOUD_PROJECT="${GOOGLE_CLOUD_PROJECT}"
REGION="${REGION}"
ZONE_A="${ZONE_A}"
ZONE_B="${ZONE_B}"
ZONE="${ZONE}"
EXTERNAL_IP="${EXTERNAL_IP}"

# VPC & subnet
NETWORK_NAME="${NETWORK_NAME}"
SUBNET_NAME="${SUBNET_NAME}"
SUBNET_REGION="${SUBNET_REGION}"
SUBNET_PRIMARY_RANGE="${SUBNET_PRIMARY_RANGE}"
PODS_RANGE_NAME="${PODS_RANGE_NAME}"
PODS_RANGE_CIDR="${PODS_RANGE_CIDR}"
SERVICES_RANGE_NAME="${SERVICES_RANGE_NAME}"
SERVICES_RANGE_CIDR="${SERVICES_RANGE_CIDR}"
ENABLE_PRIVATE_GOOGLE_ACCESS="${ENABLE_PRIVATE_GOOGLE_ACCESS}"

# Private Service Connect
PRIVATE_SERVICE_CONNECT_RANGE_NAME="${PRIVATE_SERVICE_CONNECT_RANGE_NAME}"
PRIVATE_SERVICE_CONNECT_RANGE_CIDR="${PRIVATE_SERVICE_CONNECT_RANGE_CIDR}"

# Cloud NAT
NAT_NAME="${NAT_NAME}"
NAT_REGION="${NAT_REGION}"
CLOUD_ROUTER_NAME="${CLOUD_ROUTER_NAME}"
NAT_SOURCE_SUBNETWORK_IP_RANGES="${NAT_SOURCE_SUBNETWORK_IP_RANGES}"

# Service accounts
GKE_SA_NAME="${GKE_SA_NAME}"
GKE_SA_EMAIL="${GKE_SA_EMAIL}"
NEXTCLOUD_SA_NAME="${NEXTCLOUD_SA_NAME}"
NEXTCLOUD_SA_EMAIL="${NEXTCLOUD_SA_EMAIL}"

# GKE cluster
GKE_CLUSTER_NAME="${GKE_CLUSTER_NAME}"
GKE_CLUSTER_LOCATION="${GKE_CLUSTER_LOCATION}"
GKE_CLUSTER_ZONES="${GKE_CLUSTER_ZONES}"
GKE_NODE_COUNT="${GKE_NODE_COUNT}"
GKE_MACHINE_TYPE="${GKE_MACHINE_TYPE}"
GKE_MASTER_IPV4_CIDR="${GKE_MASTER_IPV4_CIDR}"
GKE_PODS_RANGE_NAME="${GKE_PODS_RANGE_NAME}"
GKE_SERVICES_RANGE_NAME="${GKE_SERVICES_RANGE_NAME}"

# Cloud SQL
SQL_INSTANCE_NAME="${SQL_INSTANCE_NAME}"
SQL_DATABASE_VERSION="${SQL_DATABASE_VERSION}"
SQL_REGION="${SQL_REGION}"
SQL_PRIMARY_ZONE="${SQL_PRIMARY_ZONE}"
SQL_SECONDARY_ZONE="${SQL_SECONDARY_ZONE}"
SQL_TIER="${SQL_TIER}"
SQL_STORAGE_TYPE="${SQL_STORAGE_TYPE}"
SQL_STORAGE_SIZE_GB="${SQL_STORAGE_SIZE_GB}"
SQL_AUTO_STORAGE_INCREASE="${SQL_AUTO_STORAGE_INCREASE}"
SQL_BACKUP_LOCATION="${SQL_BACKUP_LOCATION}"
SQL_BACKUP_ENABLED="${SQL_BACKUP_ENABLED}"
SQL_BACKUP_RETENTION_DAYS="${SQL_BACKUP_RETENTION_DAYS}"
SQL_PITR_ENABLED="${SQL_PITR_ENABLED}"
SQL_MAINTENANCE_WINDOW_DAY="${SQL_MAINTENANCE_WINDOW_DAY}"
SQL_MAINTENANCE_WINDOW_HOUR="${SQL_MAINTENANCE_WINDOW_HOUR}"
SQL_USE_PRIVATE_IP="${SQL_USE_PRIVATE_IP}"
APP_DB_NAME="${APP_DB_NAME}"
APP_DB_CHARSET="${APP_DB_CHARSET}"
APP_DB_COLLATION="${APP_DB_COLLATION}"
SQL_ROOT_PASSWORD="${SQL_ROOT_PASSWORD}"
APP_DB_PASSWORD="${APP_DB_PASSWORD}"

# Memorystore Redis
REDIS_INSTANCE_NAME="${REDIS_INSTANCE_NAME}"
REDIS_REGION="${REDIS_REGION}"
REDIS_TIER="${REDIS_TIER}"
REDIS_MEMORY_SIZE_GB="${REDIS_MEMORY_SIZE_GB}"
REDIS_VERSION="${REDIS_VERSION}"

# Cloud Storage bucket
NEXTCLOUD_BUCKET="${NEXTCLOUD_BUCKET}"
NEXTCLOUD_BUCKET_LOCATION="${NEXTCLOUD_BUCKET_LOCATION}"
NEXTCLOUD_BUCKET_UNIFORM_ACCESS="${NEXTCLOUD_BUCKET_UNIFORM_ACCESS}"

# HMAC for Nextcloud SA (to be filled manually)
NEXTCLOUD_HMAC_ACCESS_KEY="${NEXTCLOUD_HMAC_ACCESS_KEY}"
NEXTCLOUD_HMAC_SECRET="${NEXTCLOUD_HMAC_SECRET}"

# Nextcloud / Helm
NEXTCLOUD_IMAGE_REPOSITORY="${NEXTCLOUD_IMAGE_REPOSITORY}"
NEXTCLOUD_IMAGE_TAG="${NEXTCLOUD_IMAGE_TAG}"
NEXTCLOUD_REDIS_HOST="${NEXTCLOUD_REDIS_HOST}"
NEXTCLOUD_DB_HOST="${NEXTCLOUD_DB_HOST}"
NEXTCLOUD_ADMIN_USER="${NEXTCLOUD_ADMIN_USER}"
NEXTCLOUD_ADMIN_PASSWORD="${NEXTCLOUD_ADMIN_PASSWORD}"
NEXTCLOUD_HOSTNAME="${NEXTCLOUD_HOSTNAME}"

# Timestamp
ENV_GENERATED_AT="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
ENV_EOF

echo "Environment variables saved to ${SCRIPT_DIR}/.env"
echo ""
echo "IMPORTANT: Passwords have been generated and saved to .env file."
echo "Keep this file secure and do not commit it to version control!"
