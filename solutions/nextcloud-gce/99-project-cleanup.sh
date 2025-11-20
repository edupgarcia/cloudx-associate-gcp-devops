#!/bin/bash
set -e

echo "========================================="
echo "Nextcloud GCE Cleanup"
echo "========================================="
echo ""
echo "This will delete ALL Nextcloud resources."
echo "Press Ctrl+C to cancel, or press Enter to continue..."
read

# Cloud Scheduler
echo "Deleting Cloud Scheduler job..."
gcloud scheduler jobs delete $SCHEDULER_JOB_NAME --location=$REGION --quiet || true

# Monitoring
echo "Deleting uptime check..."
gcloud monitoring uptime delete $UPTIME_CHECK_NAME --quiet || true

# Alert policies
echo "Listing alert policies..."
ALERT_POLICIES=$(gcloud alpha monitoring policies list --filter="displayName:'Nextcloud'" --format="value(name)" || true)
for policy in $ALERT_POLICIES; do
    echo "Deleting alert policy: $policy"
    gcloud alpha monitoring policies delete "$policy" --quiet || true
done

# Load Balancer components
echo "Deleting forwarding rule..."
gcloud compute forwarding-rules delete $FORWARDING_RULE_HTTP --global --quiet || true

echo "Deleting HTTP proxy..."
gcloud compute target-http-proxies delete $HTTP_PROXY_NAME --quiet || true

echo "Deleting URL map..."
gcloud compute url-maps delete $URL_MAP_NAME --quiet || true

echo "Deleting backend service..."
gcloud compute backend-services delete $BACKEND_SERVICE_NAME --global --quiet || true

echo "Deleting health check..."
gcloud compute health-checks delete $HEALTH_CHECK_NAME --quiet || true

echo "Deleting static IP..."
gcloud compute addresses delete $IP_NAME --global --quiet || true

# Cloud Armor
echo "Deleting security policy..."
gcloud compute security-policies delete $SECURITY_POLICY_NAME --quiet || true

# Instance Group
echo "Deleting managed instance group (this may take a few minutes)..."
gcloud compute instance-groups managed delete $INSTANCE_GROUP --region=$REGION --quiet || true

echo "Deleting instance template..."
gcloud compute instance-templates delete $INSTANCE_TEMPLATE --quiet || true

# Secret Manager
echo "Deleting secret..."
gcloud secrets delete $SECRET_ID --quiet || true

# Filestore
echo "Deleting Filestore instance (this may take a few minutes)..."
gcloud filestore instances delete $FILESTORE_INSTANCE_NAME --zone=$ZONE_A --quiet || true

# Redis
echo "Deleting Redis instance (this may take a few minutes)..."
gcloud redis instances delete $REDIS_INSTANCE_NAME --region=$REGION --quiet || true

# Cloud SQL
echo "Deleting Cloud SQL instance (this may take a few minutes)..."
gcloud sql instances delete $SQL_INSTANCE_NAME --quiet || true

# VPC Connector
echo "Deleting VPC connector..."
gcloud compute networks vpc-access connectors delete $VPC_CONNECTOR_NAME --region=$REGION --quiet || true

# Firewall rules
echo "Deleting firewall rules..."
gcloud compute firewall-rules delete $FW_ALLOW_HEALTH_CHECK --quiet || true
gcloud compute firewall-rules delete $FW_ALLOW_IAP --quiet || true

# VPC peering
echo "Deleting VPC peering..."
gcloud services vpc-peerings delete \
    --service=servicenetworking.googleapis.com \
    --network=$NETWORK_NAME \
    --quiet || true

# IP range allocation
echo "Deleting IP range allocation..."
gcloud compute addresses delete google-managed-services-$NETWORK_NAME --global --quiet || true

# VPC
echo "Deleting subnet..."
gcloud compute networks subnets delete $SUBNET_NAME --region=$REGION --quiet || true

echo "Deleting VPC network..."
gcloud compute networks delete $NETWORK_NAME --quiet || true

echo ""
echo "========================================="
echo "Cleanup complete!"
echo "========================================="
echo ""
echo "All Nextcloud resources have been deleted."
