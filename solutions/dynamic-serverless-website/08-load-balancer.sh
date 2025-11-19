#!/bin/bash

# Reserve a static external IP address
gcloud compute addresses create $IP_NAME \
    --global

# Create backend bucket for static content
gcloud compute backend-buckets create $BACKEND_BUCKET_NAME \
    --gcs-bucket-name=$BUCKET_NAME \
    --enable-cdn

# Create serverless NEG for Cloud Function
gcloud compute network-endpoint-groups create $NEG_NAME \
    --region=$REGION \
    --network-endpoint-type=serverless \
    --cloud-function-name=$FUNCTION_NAME

# Create backend service for Cloud Function
gcloud compute backend-services create $BACKEND_SERVICE_FUNCTION \
    --global \
    --load-balancing-scheme=EXTERNAL_MANAGED

# Add the NEG to the backend service
gcloud compute backend-services add-backend $BACKEND_SERVICE_FUNCTION \
    --global \
    --network-endpoint-group=$NEG_NAME \
    --network-endpoint-group-region=$REGION

# Create URL map with path-based routing
gcloud compute url-maps create $URL_MAP_NAME \
    --default-backend-bucket=$BACKEND_BUCKET_NAME

# Add path matcher for /api/* -> Cloud Function
gcloud compute url-maps add-path-matcher $URL_MAP_NAME \
    --path-matcher-name=api-matcher \
    --default-backend-bucket=$BACKEND_BUCKET_NAME \
    --backend-service-path-rules="/api/*=$BACKEND_SERVICE_FUNCTION"

# Create HTTP target proxy
gcloud compute target-http-proxies create $TARGET_HTTP_PROXY_NAME \
    --url-map=$URL_MAP_NAME

# Create forwarding rule
gcloud compute forwarding-rules create $FORWARDING_RULE_NAME \
    --global \
    --target-http-proxy=$TARGET_HTTP_PROXY_NAME \
    --address=$IP_NAME \
    --ports=80

# Get the load balancer IP
LB_IP=$(gcloud compute addresses describe $IP_NAME \
    --global \
    --format="value(address)")

echo "Load Balancer created successfully"
echo "Load Balancer IP: $LB_IP"
echo "Access your application at: http://$LB_IP"
