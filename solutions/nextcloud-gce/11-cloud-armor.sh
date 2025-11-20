#!/bin/bash
set -e

# Get external IP (for testing purposes - replace with your actual IP ranges)
if [ -z "$EXTERNAL_IP" ]; then
    echo "EXTERNAL_IP is not set. Getting current IP..."
    export EXTERNAL_IP="$(curl -s ifconfig.me)/32"
    echo "Using IP: $EXTERNAL_IP"
fi

echo "Creating Cloud Armor security policy..."
gcloud compute security-policies create $SECURITY_POLICY_NAME \
    --description="Nextcloud security policy"

echo "Adding allow rule for your IP..."
gcloud compute security-policies rules create 1000 \
    --security-policy=$SECURITY_POLICY_NAME \
    --expression="inIpRange(origin.ip, '$EXTERNAL_IP')" \
    --action=allow \
    --description="Allow access from known IP"

echo "Adding default deny rule..."
gcloud compute security-policies rules create 2147483647 \
    --security-policy=$SECURITY_POLICY_NAME \
    --action=deny-403 \
    --description="Default deny all"

echo "Attaching security policy to backend service..."
gcloud compute backend-services update $BACKEND_SERVICE_NAME \
    --security-policy=$SECURITY_POLICY_NAME \
    --global

echo "Cloud Armor security policy applied successfully."
echo ""
echo "Allowed IP: $EXTERNAL_IP"
echo ""
echo "To add more IPs, run:"
echo "  gcloud compute security-policies rules create PRIORITY \\"
echo "    --security-policy=$SECURITY_POLICY_NAME \\"
echo "    --expression=\"inIpRange(origin.ip, 'X.X.X.X/32')\" \\"
echo "    --action=allow"
