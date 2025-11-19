#!/bin/bash

# Create Cloud SQL instance with private IP only
gcloud sql instances create $DB_INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=$REGION \
    --network=projects/$PROJECT_ID/global/networks/$NETWORK_NAME \
    --no-assign-ip \
    --root-password=$DB_PASSWORD

# Create database
gcloud sql databases create $DB_NAME \
    --instance=$DB_INSTANCE_NAME

# Create database user
gcloud sql users create $DB_USER \
    --instance=$DB_INSTANCE_NAME \
    --password=$DB_PASSWORD

# Get the private IP address
DB_PRIVATE_IP=$(gcloud sql instances describe $DB_INSTANCE_NAME \
    --format="value(ipAddresses[0].ipAddress)")

echo "Cloud SQL instance created successfully"
echo "Private IP: $DB_PRIVATE_IP"
echo "Save this IP for the next step"
