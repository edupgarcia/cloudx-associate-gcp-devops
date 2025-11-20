# GOOGLE_CLOUD_PROJECT

# gcloud projects list
export PROJECT_ID="$GOOGLE_CLOUD_PROJECT"
export REGION="us-central1"
export ZONE_A="us-central1-a"
export ZONE_B="us-central1-b"
export ZONE_C="us-central1-c"

# Network Configuration
export NETWORK_NAME="nextcloud-vpc"
export SUBNET_NAME="nextcloud-subnet"
export SUBNET_CIDR="10.0.0.0/24"

# VPC Connector Configuration
export VPC_CONNECTOR_NAME="nextcloud-vpc-connector"
export VPC_CONNECTOR_CIDR="10.8.0.0/28"

# Firewall Configuration
export FW_ALLOW_HEALTH_CHECK="nextcloud-allow-health-check"
export FW_ALLOW_IAP="nextcloud-allow-iap"

# Cloud SQL Configuration
export SQL_INSTANCE_NAME="nextcloud-mysql"
export SQL_DATABASE="nextcloud"
export SQL_USERNAME="nextcloud"
export SQL_PASSWORD="$(openssl rand -base64 18)"

# Memorystore Redis Configuration
export REDIS_INSTANCE_NAME="nextcloud-redis"
export REDIS_AUTH="$(openssl rand -base64 18)"

# Filestore Configuration
export FILESTORE_INSTANCE_NAME="nextcloud-filestore"
export FILESTORE_SHARE_NAME="nextcloud"
export FILESTORE_CAPACITY="1TB"

# Secret Manager Configuration
export SECRET_ID="nextcloud-config"
export SECRET_VERSION="latest"

# Nextcloud Configuration
export NEXTCLOUD_USERNAME="admin"
export NEXTCLOUD_PASSWORD="$(openssl rand -base64 18)"
export NEXTCLOUD_FQDN=""  # Will be set to LB IP address

# Compute Engine Configuration
export MACHINE_TYPE="e2-standard-2"
export IMAGE_FAMILY="debian-11"
export IMAGE_PROJECT="debian-cloud"
export DISK_SIZE="50GB"

# Instance Group Configuration
export INSTANCE_TEMPLATE="nextcloud-template"
export INSTANCE_GROUP="nextcloud-ig"
export MIN_INSTANCES=1
export MAX_INSTANCES=3

# Load Balancer Configuration
export IP_NAME="nextcloud-lb-ip"
export HEALTH_CHECK_NAME="nextcloud-health-check"
export BACKEND_SERVICE_NAME="nextcloud-backend"
export URL_MAP_NAME="nextcloud-url-map"
export HTTP_PROXY_NAME="nextcloud-http-proxy"
export HTTPS_PROXY_NAME="nextcloud-https-proxy"
export FORWARDING_RULE_HTTP="nextcloud-http-rule"
export FORWARDING_RULE_HTTPS="nextcloud-https-rule"

# Cloud Armor Configuration
export SECURITY_POLICY_NAME="nextcloud-security-policy"

# Cloud Scheduler Configuration
export SCHEDULER_JOB_NAME="nextcloud-cron"
export CRON_SCHEDULE="*/5 * * * *"  # Every 5 minutes

# Monitoring Configuration
export UPTIME_CHECK_NAME="nextcloud-uptime-check"
export ALERT_POLICY_NAME="nextcloud-uptime-alert"

# Set your project ID
gcloud config set project $PROJECT_ID

# Enable required APIs
echo ''
echo 'Enabling required APIs...'

echo 'Enabling Compute Engine API...'
gcloud services enable compute.googleapis.com

echo 'Enabling VPC Access API...'
gcloud services enable vpcaccess.googleapis.com

echo 'Enabling Cloud SQL API...'
gcloud services enable sqladmin.googleapis.com

echo 'Enabling Cloud Filestore API...'
gcloud services enable file.googleapis.com

echo 'Enabling Memorystore Redis API...'
gcloud services enable redis.googleapis.com

echo 'Enabling Secret Manager API...'
gcloud services enable secretmanager.googleapis.com

echo 'Enabling Cloud Scheduler API...'
gcloud services enable cloudscheduler.googleapis.com

echo 'Enabling Cloud Monitoring API...'
gcloud services enable monitoring.googleapis.com

echo 'Enabling Cloud Logging API...'
gcloud services enable logging.googleapis.com

echo 'Enabling Cloud Resource Manager API...'
gcloud services enable cloudresourcemanager.googleapis.com

echo 'Enabling Service Networking API...'
gcloud services enable servicenetworking.googleapis.com

echo ''
echo 'All APIs enabled successfully.'
echo ''

# Display configuration
echo 'Configuration:'
echo "PROJECT_ID: ${PROJECT_ID}"
echo "REGION: ${REGION}"
echo "ZONES: ${ZONE_A}, ${ZONE_B}, ${ZONE_C}"
echo ''
echo 'Network:'
echo "  NETWORK_NAME: ${NETWORK_NAME}"
echo "  SUBNET_NAME: ${SUBNET_NAME}"
echo "  SUBNET_CIDR: ${SUBNET_CIDR}"
echo ''
echo 'Cloud SQL:'
echo "  SQL_INSTANCE_NAME: ${SQL_INSTANCE_NAME}"
echo "  SQL_DATABASE: ${SQL_DATABASE}"
echo "  SQL_USERNAME: ${SQL_USERNAME}"
echo ''
echo 'Memorystore Redis:'
echo "  REDIS_INSTANCE_NAME: ${REDIS_INSTANCE_NAME}"
echo ''
echo 'Filestore:'
echo "  FILESTORE_INSTANCE_NAME: ${FILESTORE_INSTANCE_NAME}"
echo "  FILESTORE_SHARE_NAME: ${FILESTORE_SHARE_NAME}"
echo ''
echo 'Nextcloud:'
echo "  NEXTCLOUD_USERNAME: ${NEXTCLOUD_USERNAME}"
echo ''
echo 'Instance Group:'
echo "  INSTANCE_GROUP: ${INSTANCE_GROUP}"
echo "  MIN_INSTANCES: ${MIN_INSTANCES}"
echo "  MAX_INSTANCES: ${MAX_INSTANCES}"
echo ''
echo 'Setup complete.'
echo ''

# Export all variables to .env file
echo 'Saving environment variables to .env file...'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat > "${SCRIPT_DIR}/.env" <<ENV_EOF
# Nextcloud GCE Configuration
# Generated: $(date)

# Project Configuration
PROJECT_ID="${PROJECT_ID}"
REGION="${REGION}"
ZONE_A="${ZONE_A}"
ZONE_B="${ZONE_B}"
ZONE_C="${ZONE_C}"

# Network Configuration
NETWORK_NAME="${NETWORK_NAME}"
SUBNET_NAME="${SUBNET_NAME}"
SUBNET_CIDR="${SUBNET_CIDR}"

# VPC Connector Configuration
VPC_CONNECTOR_NAME="${VPC_CONNECTOR_NAME}"
VPC_CONNECTOR_CIDR="${VPC_CONNECTOR_CIDR}"

# Firewall Configuration
FW_ALLOW_HEALTH_CHECK="${FW_ALLOW_HEALTH_CHECK}"
FW_ALLOW_IAP="${FW_ALLOW_IAP}"

# Cloud SQL Configuration
SQL_INSTANCE_NAME="${SQL_INSTANCE_NAME}"
SQL_DATABASE="${SQL_DATABASE}"
SQL_USERNAME="${SQL_USERNAME}"
SQL_PASSWORD="${SQL_PASSWORD}"

# Memorystore Redis Configuration
REDIS_INSTANCE_NAME="${REDIS_INSTANCE_NAME}"
REDIS_AUTH="${REDIS_AUTH}"

# Filestore Configuration
FILESTORE_INSTANCE_NAME="${FILESTORE_INSTANCE_NAME}"
FILESTORE_SHARE_NAME="${FILESTORE_SHARE_NAME}"
FILESTORE_CAPACITY="${FILESTORE_CAPACITY}"

# Secret Manager Configuration
SECRET_ID="${SECRET_ID}"
SECRET_VERSION="${SECRET_VERSION}"

# Nextcloud Configuration
NEXTCLOUD_USERNAME="${NEXTCLOUD_USERNAME}"
NEXTCLOUD_PASSWORD="${NEXTCLOUD_PASSWORD}"
NEXTCLOUD_FQDN="${NEXTCLOUD_FQDN}"

# Compute Engine Configuration
MACHINE_TYPE="${MACHINE_TYPE}"
IMAGE_FAMILY="${IMAGE_FAMILY}"
IMAGE_PROJECT="${IMAGE_PROJECT}"
DISK_SIZE="${DISK_SIZE}"

# Instance Group Configuration
INSTANCE_TEMPLATE="${INSTANCE_TEMPLATE}"
INSTANCE_GROUP="${INSTANCE_GROUP}"
MIN_INSTANCES=${MIN_INSTANCES}
MAX_INSTANCES=${MAX_INSTANCES}

# Load Balancer Configuration
IP_NAME="${IP_NAME}"
HEALTH_CHECK_NAME="${HEALTH_CHECK_NAME}"
BACKEND_SERVICE_NAME="${BACKEND_SERVICE_NAME}"
URL_MAP_NAME="${URL_MAP_NAME}"
HTTP_PROXY_NAME="${HTTP_PROXY_NAME}"
HTTPS_PROXY_NAME="${HTTPS_PROXY_NAME}"
FORWARDING_RULE_HTTP="${FORWARDING_RULE_HTTP}"
FORWARDING_RULE_HTTPS="${FORWARDING_RULE_HTTPS}"

# Cloud Armor Configuration
SECURITY_POLICY_NAME="${SECURITY_POLICY_NAME}"

# Cloud Scheduler Configuration
SCHEDULER_JOB_NAME="${SCHEDULER_JOB_NAME}"
CRON_SCHEDULE="${CRON_SCHEDULE}"

# Monitoring Configuration
UPTIME_CHECK_NAME="${UPTIME_CHECK_NAME}"
ALERT_POLICY_NAME="${ALERT_POLICY_NAME}"
ENV_EOF

echo "Environment variables saved to ${SCRIPT_DIR}/.env"
echo ''
echo 'IMPORTANT: Passwords have been generated and saved to .env file.'
echo 'Keep this file secure and do not commit it to version control!'
