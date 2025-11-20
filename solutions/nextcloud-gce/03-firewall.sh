#!/bin/bash
set -e

echo "Creating firewall rule for health checks..."
gcloud compute firewall-rules create $FW_ALLOW_HEALTH_CHECK \
    --network=$NETWORK_NAME \
    --action=allow \
    --direction=ingress \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --rules=tcp:80 \
    --target-tags=nextcloud-server

echo "Creating firewall rule for IAP (SSH access)..."
gcloud compute firewall-rules create $FW_ALLOW_IAP \
    --network=$NETWORK_NAME \
    --action=allow \
    --direction=ingress \
    --source-ranges=35.235.240.0/20 \
    --rules=tcp:22 \
    --target-tags=nextcloud-server

echo "Firewall rules created successfully."
