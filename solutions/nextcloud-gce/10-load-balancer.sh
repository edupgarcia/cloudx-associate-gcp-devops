#!/bin/bash
set -e

echo "Reserving static IP address..."
gcloud compute addresses create $IP_NAME \
    --global

LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")
echo "Load Balancer IP: $LB_IP"

echo "Creating health check..."
gcloud compute health-checks create http $HEALTH_CHECK_NAME \
    --port=80 \
    --request-path=/status.php \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

echo "Creating backend service..."
gcloud compute backend-services create $BACKEND_SERVICE_NAME \
    --protocol=HTTP \
    --health-checks=$HEALTH_CHECK_NAME \
    --global \
    --enable-logging \
    --logging-sample-rate=1.0 \
    --timeout=30s \
    --port-name=http

echo "Adding instance group to backend service..."
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
    --instance-group=$INSTANCE_GROUP \
    --instance-group-region=$REGION \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --capacity-scaler=1.0 \
    --global

echo "Creating URL map..."
gcloud compute url-maps create $URL_MAP_NAME \
    --default-service=$BACKEND_SERVICE_NAME

echo "Creating HTTP proxy..."
gcloud compute target-http-proxies create $HTTP_PROXY_NAME \
    --url-map=$URL_MAP_NAME

echo "Creating forwarding rule..."
gcloud compute forwarding-rules create $FORWARDING_RULE_HTTP \
    --global \
    --target-http-proxy=$HTTP_PROXY_NAME \
    --address=$IP_NAME \
    --ports=80

echo "Load balancer created successfully."
echo ""
echo "Access Nextcloud at: http://$LB_IP"
echo ""
echo "IMPORTANT: Update the NEXTCLOUD_FQDN in secret manager with this IP:"
echo "  export NEXTCLOUD_FQDN=\"$LB_IP\""
echo "  Then re-run: ./08-secret-manager.sh"
