# GOOGLE_CLOUD_PROJECT

# gcloud projects list
export PROJECT_ID="gcp-devops-basic-network"
export REGION="us-central1"
export ZONE="us-central1-a"
export NETWORK_NAME="custom-vpc"
export SUBNET_NAME="private-subnet"
export SUBNET_RANGE="10.0.0.0/24"
# curl ifconfig.me
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"

# Set your project ID
gcloud config set project $PROJECT_ID

# Enable Compute Engine API (for VMs, networks, firewalls)
gcloud services enable compute.googleapis.com

# Enable Cloud Resource Manager API (for project management)
gcloud services enable cloudresourcemanager.googleapis.com

# Enable Service Networking API (for Private Google Access)
gcloud services enable servicenetworking.googleapis.com

# Enable Cloud DNS API (optional, but useful for DNS resolution)
gcloud services enable dns.googleapis.com

# Enable OS Login API (recommended for SSH key management)
gcloud services enable oslogin.googleapis.com

# Display configuration
echo ''
echo 'Configuration:'
echo "PROJECT_ID: ${PROJECT_ID}"
echo "REGION: ${REGION}"
echo "ZONE: ${ZONE}"
echo ''
echo 'Network:'
echo "  NETWORK_NAME: ${NETWORK_NAME}"
echo "  SUBNET_NAME: ${SUBNET_NAME}"
echo "  SUBNET_RANGE: ${SUBNET_RANGE}"
echo ''
echo 'Security:'
echo "  EXTERNAL_IP: ${EXTERNAL_IP}"
echo ''
echo 'Setup complete.'
echo ''

# Export all variables to .env file
echo 'Saving environment variables to .env file...'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat > "${SCRIPT_DIR}/.env" <<ENV_EOF
# Basic Network Configuration
# Generated: $(date)

# Project Configuration
PROJECT_ID="${PROJECT_ID}"
REGION="${REGION}"
ZONE="${ZONE}"

# Network Configuration
NETWORK_NAME="${NETWORK_NAME}"
SUBNET_NAME="${SUBNET_NAME}"
SUBNET_RANGE="${SUBNET_RANGE}"

# Security Configuration
EXTERNAL_IP="${EXTERNAL_IP}"
ENV_EOF

echo "Environment variables saved to ${SCRIPT_DIR}/.env"
echo ''
echo 'If there is no personal SSH key yet, create one using the command like below'
echo 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -C "<user_email>"'

