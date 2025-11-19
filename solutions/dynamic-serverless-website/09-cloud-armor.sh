#!/bin/bash

# Create Cloud Armor security policy
gcloud compute security-policies create $SECURITY_POLICY \
    --description="IP whitelist policy for serverless website"

# Add rule to allow traffic from specific IP
gcloud compute security-policies rules create 1000 \
    --security-policy=$SECURITY_POLICY \
    --src-ip-ranges=$EXTERNAL_IP \
    --action=allow \
    --description="Allow traffic from known IP"

# Default rule to deny all other traffic
gcloud compute security-policies rules create 2147483647 \
    --security-policy=$SECURITY_POLICY \
    --src-ip-ranges='*' \
    --action=deny-403 \
    --description="Default deny rule"

# Attach security policy to backend service (Cloud Function)
gcloud compute backend-services update $BACKEND_SERVICE_FUNCTION \
    --security-policy=$SECURITY_POLICY \
    --global

# Note: Backend buckets don't support Cloud Armor directly
# You would need to put the bucket behind a backend service with a NEG if needed

echo "Cloud Armor security policy created and attached"
echo "Only traffic from $EXTERNAL_IP is allowed"
