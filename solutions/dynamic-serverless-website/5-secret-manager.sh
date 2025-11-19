#!/bin/bash

# Get the Cloud SQL private IP
DB_PRIVATE_IP=$(gcloud sql instances describe $DB_INSTANCE_NAME \
    --format="value(ipAddresses[0].ipAddress)")

# Create secret content in JSON format
SECRET_CONTENT=$(cat <<EOF
{
  "host": "$DB_PRIVATE_IP",
  "username": "$DB_USER",
  "password": "$DB_PASSWORD"
}
EOF
)

# Create secret in Secret Manager
echo "$SECRET_CONTENT" | gcloud secrets create $SECRET_NAME \
    --data-file=-

# Grant Cloud Functions service account access to the secret
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
gcloud secrets add-iam-policy-binding $SECRET_NAME \
    --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

echo "Secret created successfully in Secret Manager"
echo "Secret name: $SECRET_NAME"
