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
echo 'Setup complete.'
