#!/bin/bash

echo "Starting cleanup of dynamic serverless website resources..."

# Delete Cloud Armor security policy
gcloud compute security-policies delete $SECURITY_POLICY

# Delete Load Balancer components
gcloud compute forwarding-rules delete $FORWARDING_RULE_NAME --global
gcloud compute target-http-proxies delete $TARGET_HTTP_PROXY_NAME
gcloud compute url-maps delete $URL_MAP_NAME
gcloud compute backend-services delete $BACKEND_SERVICE_FUNCTION --global
gcloud compute backend-buckets delete $BACKEND_BUCKET_NAME
gcloud compute network-endpoint-groups delete $NEG_NAME --region=$REGION
gcloud compute addresses delete $IP_NAME --global

# Delete Cloud Function
gcloud functions delete $FUNCTION_NAME --region=$REGION --gen2

# Delete Cloud Storage bucket
gcloud storage rm -r gs://$BUCKET_NAME

# Delete Secret Manager secret
gcloud secrets delete $SECRET_NAME

# Delete Cloud SQL instance
gcloud sql instances delete $DB_INSTANCE_NAME

# Delete VPC Connector
gcloud compute networks vpc-access connectors delete $CONNECTOR_NAME --region=$REGION

# Delete VPC peering and network
gcloud services vpc-peerings delete \
    --service=servicenetworking.googleapis.com \
    --network=$NETWORK_NAME

gcloud compute addresses delete google-managed-services-$NETWORK_NAME --global
gcloud compute networks subnets delete $SUBNET_NAME --region=$REGION
gcloud compute networks delete $NETWORK_NAME

echo "Cleanup complete!"
