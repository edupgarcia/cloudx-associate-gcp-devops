# GOOGLE_CLOUD_PROJECT

# gcloud projects list
export PROJECT_ID="$GOOGLE_CLOUD_PROJECT"
export REGION="us-central1"
export ZONE="us-central1-a"

# Network Configuration
export NETWORK_NAME="serverless-vpc"
export SUBNET_NAME="serverless-subnet"
export SUBNET_RANGE="10.0.0.0/24"

# Cloud SQL Configuration
export DB_INSTANCE_NAME="serverless-mysql"
export DB_NAME="${DB_INSTANCE_NAME}-db"
export DB_USER="${DB_INSTANCE_NAME}-admin"
export DB_PASSWORD="$(base64 /dev/urandom | head -c 32)"  # Change to secure password

# Cloud Function Configuration
export FUNCTION_NAME="api-handler"
export FUNCTION_ENTRY_POINT="handler"

# Cloud Storage Configuration
export BUCKET_NAME="${PROJECT_ID}-static-content"

# Secret Manager Configuration
export SECRET_NAME="DB_CREDS"

# Security Configuration - curl ifconfig.me
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"

# Load Balancer Configuration
export LB_NAME="serverless-lb"
export BACKEND_BUCKET_NAME="backend-bucket"
export NEG_NAME="function-neg"
export BACKEND_SERVICE_FUNCTION="backend-function"
export BACKEND_SERVICE_BUCKET="backend-storage"
export URL_MAP_NAME="serverless-url-map"
export TARGET_HTTP_PROXY_NAME="serverless-http-proxy"
export FORWARDING_RULE_NAME="serverless-forwarding-rule"
export IP_NAME="serverless-lb-ip"
export SECURITY_POLICY="ip-whitelist-policy"

# VPC Connector for Cloud Function
export CONNECTOR_NAME="serverless-connector"

# Set your project ID
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable vpcaccess.googleapis.com
gcloud services enable cloudbuild.googleapis.com

echo ''
echo 'Setup complete. Update EXTERNAL_IP with your IP: export EXTERNAL_IP="$(curl -s ifconfig.me)/32"'
