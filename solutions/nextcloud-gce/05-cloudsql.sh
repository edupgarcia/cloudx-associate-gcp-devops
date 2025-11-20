#!/bin/bash
set -e

echo "Allocating IP range for private service connection..."
gcloud compute addresses create google-managed-services-$NETWORK_NAME \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --network=$NETWORK_NAME

echo "Creating private VPC connection..."
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-$NETWORK_NAME \
    --network=$NETWORK_NAME

echo "Creating Cloud SQL MySQL instance (this takes ~10 minutes)..."
gcloud sql instances create $SQL_INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-2 \
    --region=$REGION \
    --network=projects/$PROJECT_ID/global/networks/$NETWORK_NAME \
    --no-assign-ip \
    --availability-type=regional \
    --enable-bin-log \
    --backup-start-time=03:00 \
    --require-ssl

echo "Setting root password..."
gcloud sql users set-password root \
    --host=% \
    --instance=$SQL_INSTANCE_NAME \
    --password="$SQL_PASSWORD"

echo "Creating database..."
gcloud sql databases create $SQL_DATABASE \
    --instance=$SQL_INSTANCE_NAME

echo "Creating database user..."
gcloud sql users create $SQL_USERNAME \
    --instance=$SQL_INSTANCE_NAME \
    --password="$SQL_PASSWORD"

echo "Cloud SQL instance created successfully."
echo "Connection name: ${PROJECT_ID}:${REGION}:${SQL_INSTANCE_NAME}"
