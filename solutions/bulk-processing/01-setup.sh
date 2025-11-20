# GOOGLE_CLOUD_PROJECT

# gcloud projects list
export PROJECT_ID="$GOOGLE_CLOUD_PROJECT"
export REGION="us-central1"
export ZONE="us-central1-a"

# Storage Bucket Configuration
export INGEST_BUCKET="${PROJECT_ID}-ingest"
export UNPACK_BUCKET="${PROJECT_ID}-unpack"
export TRANSFORM_BUCKET="${PROJECT_ID}-transform"

# Pub/Sub Configuration
export INGEST_TOPIC="data-ingest"
export UNPACK_TOPIC="data-unpack"
export TRANSFORM_TOPIC="data-transform"
export INGEST_SUBSCRIPTION="data-ingest"
export UNPACK_SUBSCRIPTION="data-unpack"
export TRANSFORM_SUBSCRIPTION="data-transform"

# Compute Engine Configuration
export MACHINE_TYPE="e2-medium"
export IMAGE_FAMILY="debian-11"
export IMAGE_PROJECT="debian-cloud"

# Instance Template and Managed Instance Group Configuration
export UNPACK_TEMPLATE="unpack-worker-template"
export UNPACK_MIG="unpack-workers"
export TRANSFORM_TEMPLATE="transform-worker-template"
export TRANSFORM_MIG="transform-workers"

# Autoscaling Configuration
export MIN_INSTANCES=1
export MAX_INSTANCES=10
export TARGET_QUEUE_DEPTH=5

# Set your project ID
gcloud config set project $PROJECT_ID

# Enable required APIs
echo ''
echo 'Enabling required APIs...'

echo 'Enabling Compute Engine API...'
gcloud services enable compute.googleapis.com

echo 'Enabling Cloud Storage API...'
gcloud services enable storage.googleapis.com

echo 'Enabling Pub/Sub API...'
gcloud services enable pubsub.googleapis.com

echo 'Enabling Cloud Resource Manager API...'
gcloud services enable cloudresourcemanager.googleapis.com

echo ''
echo 'All APIs enabled successfully.'
echo ''

# Display configuration
echo 'Configuration:'
echo "PROJECT_ID: ${PROJECT_ID}"
echo "REGION: ${REGION}"
echo "ZONE: ${ZONE}"
echo ''
echo 'Storage Buckets:'
echo "  INGEST_BUCKET: ${INGEST_BUCKET}"
echo "  UNPACK_BUCKET: ${UNPACK_BUCKET}"
echo "  TRANSFORM_BUCKET: ${TRANSFORM_BUCKET}"
echo ''
echo 'Pub/Sub Topics:'
echo "  INGEST_TOPIC: ${INGEST_TOPIC}"
echo "  UNPACK_TOPIC: ${UNPACK_TOPIC}"
echo "  TRANSFORM_TOPIC: ${TRANSFORM_TOPIC}"
echo ''
echo 'Pub/Sub Subscriptions:'
echo "  INGEST_SUBSCRIPTION: ${INGEST_SUBSCRIPTION}"
echo "  UNPACK_SUBSCRIPTION: ${UNPACK_SUBSCRIPTION}"
echo "  TRANSFORM_SUBSCRIPTION: ${TRANSFORM_SUBSCRIPTION}"
echo ''
echo 'Managed Instance Groups:'
echo "  UNPACK_MIG: ${UNPACK_MIG}"
echo "  TRANSFORM_MIG: ${TRANSFORM_MIG}"
echo ''
echo 'Autoscaling Configuration:'
echo "  MIN_INSTANCES: ${MIN_INSTANCES}"
echo "  MAX_INSTANCES: ${MAX_INSTANCES}"
echo "  TARGET_QUEUE_DEPTH: ${TARGET_QUEUE_DEPTH}"
echo ''
echo 'Setup complete.'
echo ''

# Export all variables to .env file
echo 'Saving environment variables to .env file...'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat > "${SCRIPT_DIR}/.env" <<ENV_EOF
# Bulk Processing Configuration
# Generated: $(date)

# Project Configuration
PROJECT_ID="${PROJECT_ID}"
REGION="${REGION}"
ZONE="${ZONE}"

# Storage Bucket Configuration
INGEST_BUCKET="${INGEST_BUCKET}"
UNPACK_BUCKET="${UNPACK_BUCKET}"
TRANSFORM_BUCKET="${TRANSFORM_BUCKET}"

# Pub/Sub Configuration
INGEST_TOPIC="${INGEST_TOPIC}"
UNPACK_TOPIC="${UNPACK_TOPIC}"
TRANSFORM_TOPIC="${TRANSFORM_TOPIC}"
INGEST_SUBSCRIPTION="${INGEST_SUBSCRIPTION}"
UNPACK_SUBSCRIPTION="${UNPACK_SUBSCRIPTION}"
TRANSFORM_SUBSCRIPTION="${TRANSFORM_SUBSCRIPTION}"

# Compute Engine Configuration
MACHINE_TYPE="${MACHINE_TYPE}"
IMAGE_FAMILY="${IMAGE_FAMILY}"
IMAGE_PROJECT="${IMAGE_PROJECT}"

# Instance Template and Managed Instance Group Configuration
UNPACK_TEMPLATE="${UNPACK_TEMPLATE}"
UNPACK_MIG="${UNPACK_MIG}"
TRANSFORM_TEMPLATE="${TRANSFORM_TEMPLATE}"
TRANSFORM_MIG="${TRANSFORM_MIG}"

# Autoscaling Configuration
MIN_INSTANCES=${MIN_INSTANCES}
MAX_INSTANCES=${MAX_INSTANCES}
TARGET_QUEUE_DEPTH=${TARGET_QUEUE_DEPTH}
ENV_EOF

echo "Environment variables saved to ${SCRIPT_DIR}/.env"
echo ''
