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

# Enable APIs
# Enable compute API
echo ''
echo 'Enabling compute API...'
gcloud services enable compute.googleapis.com
echo 'Compute API enabled.'

# Enable cloud functions API
echo ''
echo 'Enabling cloud functions API...'
gcloud services enable cloudfunctions.googleapis.com
echo 'Cloud functions API enabled.'

# Enable sqladmin API
echo ''
echo 'Enabling sqladmin API...'
gcloud services enable sqladmin.googleapis.com
echo 'sqladmin API enabled.'

# Enable secret manager API
echo ''
echo 'Enabling secret manager API...'
gcloud services enable secretmanager.googleapis.com
echo 'Secret manager API enabled.'

# Enable service networking API
echo ''
echo 'Enabling service networking API...'
gcloud services enable servicenetworking.googleapis.com
echo 'Service networking API enabled.'

# Enable vpc API
echo ''
echo 'Enabling vpc API...'
gcloud services enable vpcaccess.googleapis.com
echo 'Vpc API enabled.'

# Enable cloud build API
echo ''
echo 'Enabling cloud build API...'
gcloud services enable cloudbuild.googleapis.com
echo 'Cloud build API enabled.'

# Checking variables
echo ''
echo 'Checking variables...'
echo ''
echo 'gcloud project list'
echo "PROJECT_ID: ${PROJECT_ID}"
echo "REGION: ${REGION}"
echo "ZONE: ${ZONE}"
echo ''
echo 'Network Configuration'
echo "NETWORK_NAME: ${NETWORK_NAME}"
echo "SUBNET_NAME: ${SUBNET_NAME}"
echo "SUBNET_RANGE: ${SUBNET_RANGE}"
echo ''
echo 'Cloud SQL Configuration'
echo "DB_INSTANCE_NAME: ${DB_INSTANCE_NAME}"
echo "DB_NAME: ${DB_NAME}"
echo "DB_USER: ${DB_USER}"
echo "DB_PASSWORD: ${DB_PASSWORD}"
echo ''
echo 'Cloud Function Configuration'
echo "FUNCTION_NAME: ${FUNCTION_NAME}"
echo "FUNCTION_ENTRY_POINT: ${FUNCTION_ENTRY_POINT}"
echo ''
echo 'Cloud Storage Configuration'
echo "BUCKET_NAME: ${BUCKET_NAME}"
echo ''
echo 'Secret Manager Configuration'
echo "SECRET_NAME: ${SECRET_NAME}"
echo ''
echo 'Security Configuration - curl ifconfig.me'
echo "EXTERNAL_IP: ${EXTERNAL_IP}"
echo ''
echo 'Load Balancer Configuration'
echo "LB_NAME: ${LB_NAME}"
echo "BACKEND_BUCKET_NAME: ${BACKEND_BUCKET_NAME}"
echo "NEG_NAME: ${NEG_NAME}"
echo "BACKEND_SERVICE_FUNCTION: ${BACKEND_SERVICE_FUNCTION}"
echo "BACKEND_SERVICE_BUCKET: ${BACKEND_SERVICE_BUCKET}"
echo "URL_MAP_NAME: ${URL_MAP_NAME}"
echo "TARGET_HTTP_PROXY_NAME: ${TARGET_HTTP_PROXY_NAME}"
echo "FORWARDING_RULE_NAME: ${FORWARDING_RULE_NAME}"
echo "IP_NAME: ${IP_NAME}"
echo "SECURITY_POLICY: ${SECURITY_POLICY}"
echo ''
echo 'VPC Connector for Cloud Function'
echo "CONNECTOR_NAME: ${CONNECTOR_NAME}"

echo ''
echo 'Setup complete. Update EXTERNAL_IP with your IP: export EXTERNAL_IP="$(curl -s ifconfig.me)/32"'
